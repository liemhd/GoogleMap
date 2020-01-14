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
    @IBOutlet private weak var topViewTableView: NSLayoutConstraint!
    @IBOutlet private weak var btnMenu: UIButton!
    @IBOutlet private weak var heightViewTable: NSLayoutConstraint!
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
    @IBOutlet private weak var viewHeader: UIView!
    
    //MARK: - Properties
    private var infoRoadView: InfoRoadView?
    private var viewDirection: ViewDirection?
    
    private let locationManager = CLLocationManager()
    private var itemsProvider = MoyaProvider<PlaceService>()
    private var locationUser: CLLocationCoordinate2D?
    private var locationSearch: CLLocationCoordinate2D?
    private var arrPlace: [PlaceModel] = []
    private var arrLegs: [LegsModel] = []
    private var myGroup = DispatchGroup()
    private var arrSearch: [String] = []
    
    private var polyline = GMSPolyline()
    private var marker: GMSMarker? = nil
    private var animationPolyline = GMSPolyline()
    private var path = GMSPath()
    private var animationPath = GMSMutablePath()
    private var i: UInt = 0
    private var timer: Timer!
    
    private var isHiddenAllView = true
    private var isHiddenViewDirection: Bool = true
    private var topgraphic: Topgraphic = .normal
    
    private var partialView: CGFloat {
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
    private func configView() {
        configTableView()

        /*
        Error vs tableView
        viewHeader.roundCorners(corners: [.topLeft, .topRight], radius: 6)
        */
        
        setShadow()
        
        indicator.isHidden = true
        
        textFieldSearch.addTarget(self, action: #selector(textFieldSearchClick(_:)), for: .editingDidBegin)
    }
    
    private func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        viewTable.insertSubview(bluredView, at: 0)
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: viewTable)
        let velocity = recognizer.velocity(in: viewTable)
        
        let y = viewTable.frame.minY
        if (y + translation.y >= Constants.fullView) && (y + translation.y <= partialView) {
            viewTable.frame = CGRect(x: 0, y: y + translation.y, width: viewTable.frame.width, height: viewTable.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: viewTable)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - Constants.fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            print(velocity.y)
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if velocity.y >= 0 {
                    self.viewTable.frame = CGRect(x: 0, y: self.partialView, width: self.viewTable.frame.width, height: self.viewTable.frame.height)
                } else {
                    self.viewTable.frame = CGRect(x: 0, y: Constants.fullView, width: self.viewTable.frame.width, height: self.viewTable.frame.height)
                }
            }, completion: { [weak self] _ in
                guard let wSelf = self else {return}
                if velocity.y < 0 {
                    wSelf.responseSearchTableView.isScrollEnabled = true
                }
            })
        }
    }
    
    private func configTableView() {
        responseSearchTableView.delegate = self
        responseSearchTableView.dataSource = self
        responseSearchTableView.register(UINib(nibName: ListSearchTableViewCell.name, bundle: nil), forCellReuseIdentifier: ListSearchTableViewCell.name)
        
        NSLayoutConstraint.activate([viewTable.topAnchor.constraint(equalTo: view.topAnchor, constant: 2 / 3 * view.frame.size.height)])
        
        heightViewTable.constant = view.frame.size.height - Constants.fullView
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture(_:)))
        gesture.delegate = self
        viewTable.addGestureRecognizer(gesture)

    }
    
    private func setShadow() {
        viewSearch.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
        viewTable.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
        btnShowList.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
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
    
    @objc func textFieldSearchClick(_ textField: UITextField) {
        textFieldSearch.resignFirstResponder()
        
        guard let locationUser = locationUser,
               let textSearch = textFieldSearch.text else {
            return
        }

        let sb =  UIStoryboard(name: "Main", bundle: nil)
        let searchVC = sb.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        
        if textField.tag == 0 {
            searchVC.textSearch = textSearch
            
            searchVC.searchClouse = { [weak self ] (search: String) in
                guard let wSelf = self else {return}
                wSelf.removeAllData()
                wSelf.textFieldSearch.text = search
                wSelf.btnUser.setImage(UIImage(named: "imv_clear"), for: .normal)
                wSelf.btnUser.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
                wSelf.btnMicro.isHidden = true
                wSelf.getDataSearchAPIWithLocation(searchPlace: search, location: locationUser)
                wSelf.setMyGroup(search)
            }
        }
        
        if viewDirection != nil {
            guard let textLocation = viewDirection?.textFieldYourLocation.text,
                let textLocationSearch = viewDirection?.textFieldLocationSearch.text else {
                    return
            }
            
            if textField.tag == 1 {
                if textLocation == Constants.yourLocation {
                    searchVC.textSearch = Constants.empty
                } else {
                    searchVC.textSearch = textLocation
                }
                
                searchVC.searchClouse = { [weak self] (search: String) in
                    guard let wSelf = self,
                        let textSearch = wSelf.viewDirection?.textFieldLocationSearch.text else {return}
                    wSelf.viewDirection?.textFieldYourLocation.text = search
                    wSelf.getDataSearchAPI(searchPlace: search)
                    wSelf.getDataSearchAPIWithLocation(searchPlace: textSearch, location: locationUser)
                    
                    wSelf.setMyGroup(textSearch)
                }
            } else {
                searchVC.textSearch = textLocationSearch
                
                searchVC.searchClouse = { [weak self] (search: String) in
                    guard let wSelf = self,
                        let textSearch = wSelf.viewDirection?.textFieldYourLocation.text else {return}
                    wSelf.viewDirection?.textFieldLocationSearch.text = search
                    wSelf.getDataSearchAPI(searchPlace: search)
                    wSelf.getDataSearchAPIWithLocation(searchPlace: textSearch, location: locationUser)
                    
                    wSelf.setMyGroup(textSearch)
                }
            }
        }
        
        searchVC.arrSearch = arrSearch
        searchVC.topgraphic = topgraphic
        
        searchVC.arrSearchClosures = { [weak self] (arrSearch: [String], topgraphic: Topgraphic) in
            guard let wSelf = self else {return}
            
            wSelf.arrSearch = arrSearch
            
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
        if btnShowList.isHidden == false {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        } else {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    private func getDataSearchAPI(searchPlace: String) {
        myGroup.enter()
        
        itemsProvider.request(.placeSearch(search: searchPlace)) { [weak self] (result) in
            guard let wSelf = self else { return}
            switch result {
            case .success(let response):
                let convertedString = String(data: response.data, encoding: String.Encoding.utf8)
                guard let dataAPI = convertedString else {return}
                let data = DataModel(JSONString: dataAPI)
                
                if data?.status != Constants.dataOk {
                    print("OVER_QUERY_LIMIT")
//                    wSelf.loadIndicator(isHidden: true)
                    wSelf.loadIndicator(isHidden: false)
//                    ToastView.shared.short(self!.view, txt_msg: "OVER_QUERY_LIMIT")
                    return wSelf.getDataSearchAPI(searchPlace: searchPlace)
                }
                
                guard let dataResults = data?.results,
                    let longitude = dataResults[0].geometry?.location?.lng,
                    let latitude = dataResults[0].geometry?.location?.lat,
                    var locationUser = wSelf.locationUser else {return}
                
                locationUser.longitude = longitude
                locationUser.latitude = latitude
                
                wSelf.myGroup.leave()
                
            case .failure(let err):
                print("Err: \(err)")
            }
        }
    }
    
    private func getDataSearchAPIWithLocation(searchPlace: String, location: CLLocationCoordinate2D) {
        arrPlace.removeAll()
        loadIndicator(isHidden: false)
        myGroup.enter()
        
        itemsProvider.request(.placeSearchWithLocation(searchPlace: searchPlace, location: location)) { [weak self] (result) in
            guard let wSelf = self else { return}
            switch result {
            case .success(let response):
                let convertedString = String(data: response.data, encoding: String.Encoding.utf8)
                guard let dataAPI = convertedString else {return}
                let data = DataModel(JSONString: dataAPI)
                
                if data?.status != Constants.dataOk {
                    print("OVER_QUERY_LIMIT")
//                    ToastView.shared.short(self!.view, txt_msg: "OVER_QUERY_LIMIT")
//                    return
                    wSelf.getDataSearchAPIWithLocation(searchPlace: searchPlace, location: location)
                }
                
                guard let dataResults = data?.results else {return}
                
                wSelf.arrPlace = dataResults
                wSelf.myGroup.leave()
                
            case .failure(let err):
                print("Err: \(err)")
            }
        }
    }
    
    private func getDataDirectionAPI(origin: String, destination: String, avoid: String) {
        myGroup.enter()
        arrLegs.removeAll()
        itemsProvider.request(.directions(origin: origin, destination: destination, avoid: avoid)) { [weak self] (result) in
            guard let wSelf = self else {return}
            switch result {
            case .success(let response):
                let convertedString = String(data: response.data, encoding: String.Encoding.utf8)
                guard let dataAPI = convertedString else {return}
                let data = DirectionModel(JSONString: dataAPI)
                if data?.status != Constants.dataOk {
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
                
                wSelf.addViewInfoRoad()
                wSelf.addViewDirection()
               
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
        if i < path.count() {
            animationPath.add(path.coordinate(at: i))
            animationPolyline.path = animationPath
            animationPolyline.strokeColor = .black
            animationPolyline.strokeWidth = 3
            animationPolyline.map = mapView
            i += 1
        } else {
            i = 0
            animationPath = GMSMutablePath()
            animationPolyline.map = nil
            timer.invalidate()
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
    
    private func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
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
            self.locationSearch = CLLocationCoordinate2D(latitude: (self.arrPlace[0].geometry?.location?.lat ?? 21.001218), longitude: (self.arrPlace[0].geometry?.location?.lng ?? 105.800716))
            
            guard let locationUser = self.locationUser,
                    let locationSearch = self.locationSearch else {return}
            
            let bounds = GMSCoordinateBounds(coordinate: locationUser, coordinate: locationSearch)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
            
            self.loadIndicator(isHidden: true)
            
            if self.arrPlace.count > 1 {
                if self.isHiddenViewDirection == false {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                        self.viewTable.alpha = 0
                    }, completion: { _ in
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
                    self.viewSearch.alpha = 0
                }, completion: { _ in
                    self.viewSearch.isHidden = true
                    self.responseSearchTableView.reloadData()
                })
                
                self.getDataDirectionAPI(origin: "\(locationUser.latitude),\(locationUser.longitude)", destination: "\(locationSearch.latitude),\(locationSearch.longitude)", avoid: "highways")
                
                self.isHiddenViewDirection = true

                self.setMarker(position: locationSearch, title: searchPlace)
            }
            
            guard let timer = self.timer else {return}
            timer.invalidate()
        }
    }
    
    private func setMarker(position: CLLocationCoordinate2D, title: String) {
        marker = GMSMarker(position: position)
        marker?.icon = GMSMarker.markerImage(with: .red)
        marker?.title = title
        marker?.map = mapView
    }
    
    private func addViewInfoRoad() {
        if infoRoadView == nil {
            infoRoadView = Bundle.main.loadNibNamed("InfoRoadView", owner: self, options: nil)?.first as? InfoRoadView
            view.addSubview(infoRoadView ?? UIView())
            infoRoadView?.frame = CGRect(x: 0, y: view.frame.maxY - (view.frame.height / 5), width: view.frame.width, height: view.frame.height / 5)
            infoRoadView?.fillData(data: arrLegs[0].duration?.text ?? Constants.empty)
        }
    }
    
    private func addViewDirection() {
        if viewDirection == nil {
            viewDirection = Bundle.main.loadNibNamed("ViewDirection", owner: self, options: nil)?.first as? ViewDirection
            view.addSubview(viewDirection ?? UIView())
            viewDirection?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 150)
            viewDirection?.fillTextSearch(text: textFieldSearch.text ?? "")
            viewDirection?.textFieldYourLocation.addTarget(self, action: #selector(textFieldSearchClick(_:)), for: .editingDidBegin)
            viewDirection?.textFieldLocationSearch.addTarget(self, action: #selector(textFieldSearchClick(_:)), for: .editingDidBegin)
            
            viewDirection?.directionDelegate = self
            
            autoLayoutTopographicAndBtnLocation()
        }
    }
    
    private func autoLayoutTopographicAndBtnLocation() {
        if viewDirection != nil {
            guard let viewDirection = viewDirection else {return}
            btnSetTopographic.topAnchor.constraint(equalTo: viewDirection.bottomAnchor, constant: 32).isActive = true
            
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: infoRoadView?.frame.height ?? 0 + 16, right: 0)
        }
    }
    
    private func hiddenAllView() {
        isHiddenViewDirection = true
        isHiddenAllView = true
        btnMicro.isHidden = false
        viewTable.isHidden = true
        btnShowList.isHidden = true
        loadIndicator(isHidden: true)
        
        removeAllData()
    }
    
    private func removeAllData() {
        textFieldSearch.text = nil
        btnUser.setImage(UIImage(named: "imv_user"), for: .normal)
        btnMenu.setImage(UIImage(named: "imv_menu"), for: .normal)
        btnUser.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        arrPlace.removeAll()
        mapView.clear()
        view.layoutIfNeeded()
        guard let timer = timer else {return}
        timer.invalidate()
    }
    
    //MARK: - Action
    @IBAction private func btnActionMenu(_ sender: Any) {
        guard let checkImage = btnMenu.currentImage?.isEqual(UIImage(named: "imv_back")) else {
            return
        }
        
        if checkImage {
            polyline.map = nil
            marker?.map = nil
            btnShowList.isHidden = false
        }
    }
    
    @IBAction private func btnActionMicro(_ sender: Any) {
    }
    
    @IBAction private func btnActionLogin(_ sender: Any) {
        guard let checkImage = btnUser.currentImage?.isEqual(UIImage(named: "imv_user")),
                let locationUser = locationUser else {
            return
        }
        if !checkImage {
            UIView.animate(withDuration: 0.3) {
                self.forcusLocation(locationUser, zoom: 15)
                self.hiddenAllView()
                
                if self.infoRoadView != nil {
                    self.infoRoadView?.removeFromSuperview()
                    self.infoRoadView = nil
                }
            }
        }
    }
    
    @IBAction private func btnActionShowList(_ sender: Any) {
        viewTable.frame = CGRect(x: 0, y: partialView, width: viewTable.frame.width, height: viewTable.frame.height)
        
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
            UIApplication.shared.statusBarStyle = .default
            switch topgraphic {
            case .terrain:
                wSelf.mapView.mapType = .terrain
                wSelf.topgraphic = .terrain
            case .normal:
                wSelf.mapView.mapType = .normal
                wSelf.topgraphic = .normal
            case .hybird:
                wSelf.mapView.mapType = .hybrid
                wSelf.topgraphic = .hybird
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
        
        present(vc, animated: true, completion: nil)
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
                if self.infoRoadView == nil {
                    self.changedLocationBtn()
                }
            })
            
            if arrPlace.count > 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.viewTable.alpha = 0
                }, completion: { _ in
                    self.viewTable.isHidden = true
                })
                isHiddenViewDirection = true
            }
            
            if arrPlace.count == 1 {
                isHiddenViewDirection = true
            }
            
            isHiddenAllView = false
        } else {
            if arrPlace.count == 1 {
                self.isHiddenViewDirection = true
            }
            
            if arrPlace.count > 1 {
                if self.isHiddenViewDirection == false {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    }, completion: { _ in
                    })
                    
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                        self.btnShowList.alpha = 1
                    }, completion: { _ in
                        self.btnShowList.isHidden = false
                        if self.infoRoadView == nil {
                            self.changedLocationBtn()
                        }
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
        
        let coorSelected = CLLocationCoordinate2D(latitude: (arrPlace[indexPath.row].geometry?.location?.lat ?? 21.001218), longitude: (arrPlace[indexPath.row].geometry?.location?.lng ?? 105.800716))
        let title = arrPlace[indexPath.row].name
        setMarker(position: coorSelected, title: title ?? "")
        
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

        guard let latitude = arrPlace[indexPath.row].geometry?.location?.lat,
            let longitude = arrPlace[indexPath.row].geometry?.location?.lng else {
            return cell
        }

        let locationSearch = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let marker = GMSMarker(position: locationSearch)
        guard let str = arrPlace[indexPath.row].icon,
                   let url = URL(string: str),
                   let data = try? Data(contentsOf: url),
                    let imageIcon = UIImage(data: data) else {return cell}

        marker.icon = imageWithImage(image: imageIcon, scaledToSize: CGSize(width: 20.0, height: 20.0))
        marker.title = arrPlace[indexPath.row].name
        marker.map = mapView

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
        if (y == Constants.fullView && responseSearchTableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            responseSearchTableView.isScrollEnabled = false
        } else {
            responseSearchTableView.isScrollEnabled = true
        }
        
        return false
    }
}

extension HomeViewController: DirectionDelegate {
    func removeView() {
        guard let locationUser = locationUser else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.viewSearch.alpha = 1
            self.viewSearch.isHidden = false
            self.forcusLocation(locationUser, zoom: 15)
            self.hiddenAllView()
        }
        viewDirection?.removeFromSuperview()
        infoRoadView?.removeFromSuperview()
        viewDirection = nil
        infoRoadView = nil
    }
}
