//
//  ViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Moya
import GooglePlaces

final class HomeViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var topViewTableView: NSLayoutConstraint!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var heightViewTable: NSLayoutConstraint!
    @IBOutlet private weak var textFieldSearch: UITextField!
    @IBOutlet private weak var viewSearch: UIView!
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var responseSearchTableView: UITableView!
    @IBOutlet private weak var btnShowList: UIButton!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var btnSetTopographic: UIButton!
    @IBOutlet private weak var btnMicro: UIButton!
    @IBOutlet private weak var btnUser: UIButton!
    @IBOutlet private weak var viewTable: UIView!
    @IBOutlet private weak var viewRoadInfo: UIView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet weak var viewHeader: UIView!
    
    //MARK: - Properties
    private let locationManager = CLLocationManager()
    var itemsProvider = MoyaProvider<PlaceService>()
    var locationUser: CLLocationCoordinate2D?
    var arrPlace: [PlaceModel] = []
    var arrLegs: [LegsModel] = []
    var myGroup = DispatchGroup()
    private var arrSearch: [String] = []
    
    var polyline = GMSPolyline()
    var marker: GMSMarker? = nil
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!
    
    var isHiddenAllView = true
    var isHiddenViewDirection: Bool = true
    var topgraphic: Topgraphic = .normal
    
    let fullView: CGFloat = 70
    var partialView: CGFloat {
        return 2 / 3 * view.frame.size.height
    }
    
    //MARK: - View Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()
        configureMapView()
        configView()
    }
    
    override func viewWillLayoutSubviews() {
        setShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.viewTable.frame
            let yComponent = self?.partialView
            self?.viewTable.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height - 100)
        })
    }
    
    //MARK: - Function
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        viewTable.insertSubview(bluredView, at: 0)
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.viewTable)
        let velocity = recognizer.velocity(in: self.viewTable)
        
        let y = self.viewTable.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.viewTable.frame = CGRect(x: 0, y: y + translation.y, width: viewTable.frame.width, height: viewTable.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.viewTable)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            print(velocity.y)
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.viewTable.frame = CGRect(x: 0, y: self.partialView, width: self.viewTable.frame.width, height: self.viewTable.frame.height)
                } else {
                    self.viewTable.frame = CGRect(x: 0, y: self.fullView, width: self.viewTable.frame.width, height: self.viewTable.frame.height)
                }
                
            }, completion: { [weak self] _ in
                if ( velocity.y < 0 ) {
                    self?.responseSearchTableView.isScrollEnabled = true
                }
            })
        }
    }
    
    private func setShadow() {
        viewSearch.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
        viewTable.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
        btnShowList.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
    }
    
    private func configView() {
        responseSearchTableView.delegate = self
        responseSearchTableView.dataSource = self
        responseSearchTableView.register(UINib(nibName: ListSearchTableViewCell.name, bundle: nil), forCellReuseIdentifier: ListSearchTableViewCell.name)
        
        NSLayoutConstraint.activate([viewTable.topAnchor.constraint(equalTo: view.topAnchor, constant: 2 / 3 * view.frame.size.height)])
        
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture(_:)))
        gesture.delegate = self
        viewTable.addGestureRecognizer(gesture)
        
        heightViewTable.constant = view.frame.size.height - fullView
        //Error vs tableView
//        viewHeader.roundCorners(corners: [.topLeft, .topRight], radius: 6)
        
        setShadow()
        indicator.isHidden = true
        
        textFieldSearch.addTarget(self, action: #selector(textFieldClick(_:)), for: .editingDidBegin)
    }
    
    private func configureMapView() {
        mapView.settings.myLocationButton = true
        mapView.mapType = .normal
        mapView.settings.rotateGestures = true
        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        mapView.layoutMargins = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
        
    }
    
    @objc func textFieldClick(_ textField: UITextField) {
        textFieldSearch.resignFirstResponder()
        
        guard let locationUser = locationUser,
               let textSearch = textFieldSearch.text else {
            return
        }

        let sb =  UIStoryboard(name: "Main", bundle: nil)
        let searchVC = sb.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        searchVC.textSearch = textSearch
        searchVC.arrSearch = arrSearch
        searchVC.topgraphic = self.topgraphic
        
        searchVC.searchClouse = { [weak self ] (search: String) in
            guard let wSelf = self else {return}
            wSelf.textFieldSearch.text = search
            wSelf.btnUser.setImage(UIImage(named: "imv_clear"), for: .normal)
            wSelf.btnUser.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            wSelf.btnMicro.isHidden = true
            wSelf.getDataSearchAPI(searchPlace: search, location: locationUser)
            wSelf.setMyGroup(search)
            
        }
        searchVC.arrSearchClosures = { [weak self] (arrSearch: [String]) in
            guard let wSelf = self else {return}
            wSelf.arrSearch = arrSearch
        }
        
        searchVC.topgraphicClosures = { [weak self] (topgraphic: Topgraphic) in
            guard let _ = self else {return}
            
            switch topgraphic {
            case .terrain, .normal:
                UIApplication.shared.statusBarStyle = .default
            default:
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
        
        present(searchVC, animated: true, completion: nil)
    }
    
    private func changedLocationBtn() {
        if self.btnShowList.isHidden == false {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

        } else {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        }
    }
    
    private func getDataSearchAPI(searchPlace: String, location: CLLocationCoordinate2D) {
        self.arrPlace.removeAll()
        loadIndicator(isHidden: false)
        myGroup.enter()
        itemsProvider.request(.placeSearch(searchPlace: searchPlace, location: location)) { [weak self] (result) in
            guard let wSelf = self else { return}
            switch result {
            case .success(let response):
                let convertedString = String(data: response.data, encoding: String.Encoding.utf8)
                guard let dataAPI = convertedString else {return}
                let data = DataModel(JSONString: dataAPI)
                guard let dataResults = data?.results else {return}
                if data?.status != "OK" {
                    wSelf.loadIndicator(isHidden: true)
                    ToastView.shared.short(self!.view, txt_msg: "OVER_QUERY_LIMIT")
                    return
                }
                
                wSelf.arrPlace = dataResults
                wSelf.myGroup.leave()
                
            case .failure(let err):
                print("Err: \(err)")
            }
        }
    }
    
    private func getDataDirectionAPI(origin: String, destination: String, avoid: String) {
        myGroup.enter()
        self.arrLegs.removeAll()
        itemsProvider.request(.directions(origin: origin, destination: destination, avoid: avoid)) { [weak self] (result) in
            guard let wSelf = self else {return}
            switch result {
            case .success(let response):
                let convertedString = String(data: response.data, encoding: String.Encoding.utf8)
                guard let dataAPI = convertedString else {return}
                let data = DirectionModel(JSONString: dataAPI)
                if data?.status != "OK" {
                    ToastView.shared.short(self!.view, txt_msg: "OVER_QUERY_LIMIT")
                    return
                }
                guard let arrRouters = data?.routes else {return}
                for router in arrRouters {
                    guard let arrLegs = router.legs else {return}
                    for legs in arrLegs {
                        wSelf.arrLegs.append(legs)
                    }
                }
                
                wSelf.timeLabel.text = "\(wSelf.arrLegs[0].distance?.text ?? "") (\(wSelf.arrLegs[0].duration?.text ?? ""))"
               
                if arrRouters.count > 0 {
                    let routes = arrRouters[0]
                    let routeOverviewPolyline = routes.overview_polyline
                    let point = routeOverviewPolyline?.points
                    guard let poin = point else {return}
                    wSelf.path = GMSPath.init(fromEncodedPath: poin) ?? wSelf.path
                    wSelf.polyline.path = wSelf.path
                    wSelf.polyline.strokeColor = .blue
                    wSelf.polyline.strokeWidth = 3.0
                    wSelf.polyline.map = wSelf.mapView
                    wSelf.timer = Timer.scheduledTimer(timeInterval: 0.003, target: wSelf, selector: #selector(wSelf.animatePolylinePath), userInfo: nil, repeats: true)
                }
               
                wSelf.myGroup.leave()
            case .failure(let err):
                print("Error: \(err)")
            }
        }
    }
    
    @objc func animatePolylinePath() {
        if self.i < self.path.count() {
            self.animationPath.add(self.path.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = .black
            self.animationPolyline.strokeWidth = 3
            self.animationPolyline.map = self.mapView
            self.i += 1
        } else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
            self.timer.invalidate()
        }
    }
    
    private func configureLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
    }
    
    private func forcusLocation(_ coordinate: CLLocationCoordinate2D, zoom: Float) {
        mapView.animate(to: GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom))
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func loadIndicator(isHidden: Bool) {
        indicator.isHidden = isHidden
        if isHidden == false {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
    
    private func setMyGroup(_ searchPlace: String) {
        myGroup.notify(queue: DispatchQueue.main) {
            guard let locationUser = self.locationUser else {return}
            
            let locationSearch = CLLocationCoordinate2D(latitude: (self.arrPlace[0].geometry?.location?.lat ?? 21.001218), longitude: (self.arrPlace[0].geometry?.location?.lng ?? 105.800716))
            
            let bounds = GMSCoordinateBounds(coordinate: locationUser, coordinate: locationSearch)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
            
            self.loadIndicator(isHidden: true)
            
            if self.arrPlace.count > 1 {
                if self.isHiddenViewDirection == false {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                        self.viewRoadInfo.alpha = 1
                        self.viewTable.alpha = 0
                    }, completion: { _ in
                        self.viewRoadInfo.isHidden = false
                        self.viewTable.isHidden = true
                        self.responseSearchTableView.reloadData()

                    })
                    
                    self.isHiddenViewDirection = true

                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                        self.viewTable.alpha = 1
                    }, completion: { _ in
                        self.viewTable.isHidden = false
                        self.responseSearchTableView.reloadData()

                    })
                    self.isHiddenViewDirection = false
                }

            }
            
            if self.arrPlace.count == 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.viewRoadInfo.alpha = 1
                }, completion: { _ in
                    self.viewRoadInfo.isHidden = false
                    self.responseSearchTableView.reloadData()

                })
                
                self.isHiddenViewDirection = true

                self.setMarker(position: locationSearch, title: searchPlace)

                self.getDataDirectionAPI(origin: "\(locationUser.latitude),\(locationUser.longitude)", destination: "\(locationSearch.latitude),\(locationSearch.longitude)", avoid: "highways")
                
                

            }
            
            guard let timer = self.timer else {return}
            timer.invalidate()
            
        }
    }
    
    private func setMarker(position: CLLocationCoordinate2D, title: String) {
        self.marker = GMSMarker(position: position)
        self.marker?.icon = GMSMarker.markerImage(with: .red)
        self.marker?.title = title
        self.marker?.map = self.mapView
    }
    
    
    //MARK: - Action
    @IBAction private func btnActionOptional(_ sender: Any) {
    }
    @IBAction private func btnActionStart(_ sender: Any) {
    }
    
    @IBAction private func btnActionMenu(_ sender: Any) {
        guard let checkImage = btnMenu.currentImage?.isEqual(UIImage(named: "imv_back")) else {
            return
        }
        
        if checkImage {
            polyline.map = nil
            marker?.map = nil
            viewRoadInfo.isHidden = true
            btnShowList.isHidden = false
            
        } else {
            
        }
    }
    
    @IBAction private func btnActionMicro(_ sender: Any) {
    }
    @IBAction private func btnActionLogin(_ sender: Any) {
        guard let checkImage = btnUser.currentImage?.isEqual(UIImage(named: "imv_user")),
                let locationUser = locationUser else {
            return
        }
        if (checkImage) {
            
        } else {
            UIView.animate(withDuration: 0.3) {
                self.arrPlace.removeAll()
                self.isHiddenViewDirection = true
                self.isHiddenAllView = true
                self.btnUser.setImage(UIImage(named: "imv_user"), for: .normal)
                self.btnMenu.setImage(UIImage(named: "imv_menu"), for: .normal)
                self.btnUser.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                self.textFieldSearch.text = nil
                self.btnMicro.isHidden = false
                self.viewRoadInfo.isHidden = true
                self.viewTable.isHidden = true
                self.btnShowList.isHidden = true
                self.loadIndicator(isHidden: true)
                self.mapView.clear()
                self.forcusLocation(locationUser, zoom: 15)
                self.view.layoutIfNeeded()
                guard let timer = self.timer else {return}
                timer.invalidate()
            }
        }
    }
    
    @IBAction private func btnActionShowList(_ sender: Any) {
        self.viewTable.frame = CGRect(x: 0, y: self.partialView, width: self.viewTable.frame.width, height: self.viewTable.frame.height)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.btnShowList.alpha = 0
            self.viewTable.alpha = 1
        }, completion: { _ in
            self.viewTable.isHidden = false
            self.btnShowList.isHidden = true
        })
    }
    
    @IBAction private func btnActionTopographic(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Topographic") as! PopupTopographicViewController
        
        vc.topgraphicClosures = { [weak self] (topgraphic: Topgraphic) in
            guard let wSelf = self else {return}
            switch topgraphic {
            case .terrain:
                wSelf.mapView.mapType = .terrain
                wSelf.topgraphic = .terrain
                UIApplication.shared.statusBarStyle = .default
            case .normal:
                wSelf.mapView.mapType = .normal
                wSelf.topgraphic = .normal
                UIApplication.shared.statusBarStyle = .default
            case .hybird:
                wSelf.mapView.mapType = .hybrid
                wSelf.topgraphic = .hybird
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    
   
    @IBAction private func btnActionSearch(_ sender: Any) {
        guard let searchPlace = textFieldSearch.text,
            let location = locationUser else {
                return
        }
        
        if !searchPlace.isEmpty {
            self.mapView.clear()
            getDataSearchAPI(searchPlace: searchPlace, location: location)
            setMyGroup(searchPlace)
            
        }
    }
    
}

//MARK: - GMSMapViewDelegate
extension HomeViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if isHiddenAllView == true {
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                self.viewSearch.alpha = 0
                self.btnShowList.alpha = 0
                self.btnSetTopographic.alpha = 0
            }, completion: { _ in
                
                mapView.settings.myLocationButton = false
                
                self.viewSearch.isHidden = true
                self.btnShowList.isHidden = true
                self.btnSetTopographic.isHidden = true
                UIApplication.shared.isStatusBarHidden = true
                self.changedLocationBtn()
            })
            
            if arrPlace.count > 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.viewTable.alpha = 0
                    self.viewRoadInfo.alpha = 0
                }, completion: { _ in
                    self.viewTable.isHidden = true
                    self.viewRoadInfo.isHidden = true
                })
                isHiddenViewDirection = true
                
            }
            
            if arrPlace.count == 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.viewRoadInfo.alpha = 0
                }, completion: { _ in
                    self.viewRoadInfo.isHidden = true
                })
                isHiddenViewDirection = true
            }
            
            isHiddenAllView = false
            
        } else {
            
            if arrPlace.count == 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.viewRoadInfo.alpha = 1
                }, completion: { _ in
                    self.viewRoadInfo.isHidden = false
                })
                
                self.isHiddenViewDirection = true
            }
            
            if arrPlace.count > 1 {
                if self.isHiddenViewDirection == false {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                        self.viewRoadInfo.alpha = 1
                    }, completion: { _ in
                        self.viewRoadInfo.isHidden = false
                    })
                    
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                        self.btnShowList.alpha = 1
                    }, completion: { _ in
                        self.btnShowList.isHidden = false
                        self.changedLocationBtn()
                    })
                }
                self.isHiddenViewDirection = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                self.viewSearch.alpha = 1
                self.btnSetTopographic.alpha = 1
            }, completion: { _ in
                self.viewSearch.isHidden = false
                mapView.settings.myLocationButton = true
                self.btnSetTopographic.isHidden = false
                UIApplication.shared.isStatusBarHidden = false
            })
            
            isHiddenAllView = true
        }
//        print(isHiddenViewDirection)
    }
    
}

//MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        forcusLocation(location.coordinate, zoom: 15)
        locationUser = location.coordinate;

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        case.authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            fatalError()
        }
    }
}

//MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.clear()
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = sb.instantiateViewController(withIdentifier: "DetailPlace") as? DetailPlaceViewController else {
            return
        }
        
        let coorSelected = CLLocationCoordinate2D(latitude: (self.arrPlace[indexPath.row].geometry?.location?.lat ?? 21.001218), longitude: (self.arrPlace[indexPath.row].geometry?.location?.lng ?? 105.800716))
        let title = self.arrPlace[indexPath.row].name
        self.setMarker(position: coorSelected, title: title ?? "")
        
        detailVC.directionClosures = { [weak self] (placeData: PlaceModel) in
            
            guard let wSelf = self,
                let latitude = placeData.geometry?.location?.lat,
                let longitude = placeData.geometry?.location?.lng,
                let locationUser = wSelf.locationUser,
                   let searchName = placeData.name else {
                return
            }
            
            wSelf.btnMenu.setImage(UIImage(named: "imv_back"), for: .normal)
            
            wSelf.isHiddenViewDirection = false
            
            let bounds = GMSCoordinateBounds(coordinate: locationUser, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            wSelf.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
            
            let coor = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            wSelf.getDataDirectionAPI(origin: "\(locationUser.latitude),\(locationUser.longitude)", destination: "\(coor.latitude),\(coor.longitude)", avoid: "highways")
            
            wSelf.setMyGroup(searchName)
        }
        
        detailVC.placeData = arrPlace[indexPath.row]
        present(detailVC, animated: true, completion: nil)
    }
   
}

//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = responseSearchTableView.dequeueReusableCell(withIdentifier: ListSearchTableViewCell.name, for: indexPath) as? ListSearchTableViewCell else {
            return UITableViewCell()
        }

        if let photo = arrPlace[indexPath.row].photos?.first?.photo_reference {
            cell.fillData(placeModel: arrPlace[indexPath.row], photo: getDataPlacePhoto(photoReference: photo))

        }

        guard let latitude = self.arrPlace[indexPath.row].geometry?.location?.lat,
            let longitude = self.arrPlace[indexPath.row].geometry?.location?.lng else {
            return cell
        }

        let locationSearch = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let marker = GMSMarker(position: locationSearch)
        guard let str = arrPlace[indexPath.row].icon,
                   let url = URL(string: str),
                   let data = try? Data(contentsOf: url),
                    let imageIcon = UIImage(data: data) else {return cell}

        marker.icon = self.imageWithImage(image: imageIcon, scaledToSize: CGSize(width: 20.0, height: 20.0))
        marker.title = arrPlace[indexPath.row].name
        marker.map = self.mapView

        return cell
    }
}

//MARK: - GMSAutocompleteViewControllerDelegate
extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        print("Place name: \(place.name)")
//        print("Place ID: \(place.placeID)")
//        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)

    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: viewTable).y
        
        let y = viewTable.frame.minY
        if (y == fullView && responseSearchTableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            responseSearchTableView.isScrollEnabled = false
        } else {
            responseSearchTableView.isScrollEnabled = true
        }
        
        return false
    }
}
