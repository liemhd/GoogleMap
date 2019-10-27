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

final class ViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet private weak var viewSearch: UIView!
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var responseSearchTableView: UITableView!
    @IBOutlet private weak var btnShowList: UIButton!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var btnSetTopographic: UIButton!
    @IBOutlet weak var btnMicro: UIButton!
    @IBOutlet weak var btnUser: UIButton!
    
    //MARK: - Properties
    private let locationManager = CLLocationManager()
    var itemsProvider = MoyaProvider<PlaceService>()
    var locationUser: CLLocationCoordinate2D?
    var locationSearch: CLLocation?
    var arrPlace: [PlaceModel] = []
    let myGroup = DispatchGroup()
    var checkShow = false
    var defaultOffSet: CGPoint?
    var tableViewOrigin: CGPoint?
    let path = GMSMutablePath()
    
    
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
    
    //MARK: - Function
    private func setShadow() {
        viewSearch.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
        btnShowList.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
        responseSearchTableView.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
    }
    
    func configView() {
        responseSearchTableView.delegate = self
        responseSearchTableView.dataSource = self
        responseSearchTableView.register(UINib(nibName: ListSearchTableViewCell.name, bundle: nil), forCellReuseIdentifier: ListSearchTableViewCell.name)
        
        setShadow()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        responseSearchTableView.addGestureRecognizer(pan)
        
        tableViewOrigin = responseSearchTableView.frame.origin
        
        indicator.isHidden = true
        
        textFieldSearch.addTarget(self, action: #selector(textFieldClick(_:)), for: .editingDidBegin)
    }
    
    @objc func textFieldClick(_ textField: UITextField) {
        textFieldSearch.resignFirstResponder()

        let sb =  UIStoryboard(name: "Main", bundle: nil)
        let searchVC = sb.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        searchVC.textSearch = textFieldSearch.text!
        searchVC.searchClouse = { [weak self ] (search: String) in
            guard let wSelf = self else {return}
            wSelf.textFieldSearch.text = search
            wSelf.btnUser.setImage(UIImage(named: "imv_clear"), for: .normal)
            wSelf.btnUser.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            wSelf.btnMicro.isHidden = true
            wSelf.getDataAPI(searchPlace: search, location: wSelf.locationUser!)
            wSelf.setMyGroup(search)
            
        }
        
        present(searchVC, animated: true, completion: nil)
    }
    
    @objc func panGesture(_ pan: UIPanGestureRecognizer) {
        let tableView = pan.view
        let translation = pan.translation(in: view)
        
        switch pan.state {
        case .began, .changed:
//            if self.responseSearchTableView.frame.origin.y == 60 {
//                tableView?.center = CGPoint(x: (tableView?.center.x)!, y: (tableView?.center.y)! + translation.y)
//                pan.setTranslation(CGPoint.zero, in: view)
//            }
            tableView?.center = CGPoint(x: (tableView?.center.x)!, y: (tableView?.center.y)! + translation.y)
            pan.setTranslation(CGPoint.zero, in: view)
            
            if self.responseSearchTableView.frame.origin.y <= 185 {
                self.heightTableView.constant = self.view.bounds.height - 60
            }
            
            if self.responseSearchTableView.frame.origin.y >= 450 {
                UIView.animate(withDuration: 0.3) {
                    self.btnShowList.isHidden = false
                }
                
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.btnShowList.isHidden = true
                }
            }
            self.changedLocationBtn()
//            print(tableView?.frame.origin.y ?? 0)
            print("\(self.responseSearchTableView.frame.origin.y) ---- \(self.view.frame.origin.y)" )

            
        case .ended:
            if self.responseSearchTableView.frame.origin.y >= 300 {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.responseSearchTableView.alpha = 0
                    self.btnShowList.alpha = 1
                }) { _ in
                    self.responseSearchTableView.isHidden = true
                    self.btnShowList.isHidden = false
                    self.changedLocationBtn()
                }
            } else if self.responseSearchTableView.frame.origin.y < 150 {
                UIView.animate(withDuration: 0.3) {
                    self.responseSearchTableView.frame.origin.y = 60
                    self.heightTableView.constant = self.view.bounds.height - 46
                }
            }  else {
                UIView.animate(withDuration: 0.3) {
                    self.responseSearchTableView.frame.origin = self.tableViewOrigin!
                }
            }
            
            self.changedLocationBtn()
            
        default:
            break
        }
    }
    
    func changedLocationBtn() {
        if self.btnShowList.isHidden == false {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

        } else {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        }
    }
    
    private func getDataAPI(searchPlace: String, location: CLLocationCoordinate2D) {
        loadIndicator(isHidden: false)
        myGroup.enter()
        itemsProvider.request(.placeSearch(searchPlace: searchPlace, location: location)) { [weak self] (result) in
            guard let wSelf = self else { return}
            switch result {
            case .success(let response):
                let convertedString = String(data: response.data, encoding: String.Encoding.utf8)
                guard let dataAPI = convertedString else {return}
                let data = DataModel(JSONString: dataAPI)
                if data?.status != "OK" {
                    wSelf.loadIndicator(isHidden: true)
                    ToastView.shared.short(self!.view, txt_msg: "OVER_QUERY_LIMIT")
                    return
                }
                wSelf.arrPlace = data!.results!
                wSelf.myGroup.leave()
                
            case .failure(let err):
                print("Err: \(err)")
            }
        }
    }
    
    private func configureLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
    }
    
    private func configureMapView() {
        mapView.settings.myLocationButton = true
//        mapView.mapType = .hybrid
        mapView.settings.rotateGestures = true
        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        mapView.layoutMargins = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)

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
    
    private func getDataPlacePhoto(photoReference: String) -> String {
        let dataPhotos = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(KEY)"
        
        return dataPhotos
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        forcusLocation(locationUser!, zoom: 15)
        return true
    }
    
    //MARK: - Action
    @IBAction func btnActionMenu(_ sender: Any) {
    }
    @IBAction func btnActionMicro(_ sender: Any) {
    }
    @IBAction func btnActionLogin(_ sender: Any) {
        if (btnUser.currentImage?.isEqual(UIImage(named: "imv_user")))! {
            print("a")
        } else {
            UIView.animate(withDuration: 0.3) {
                self.btnUser.setImage(UIImage(named: "imv_user"), for: .normal)
                self.btnUser.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                self.textFieldSearch.text = nil
                self.btnMicro.isHidden = false
            }
        }
    }
    @IBAction func btnActionShowList(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.responseSearchTableView.alpha = 1
            self.btnShowList.alpha = 0
        }, completion: { _ in
            self.responseSearchTableView.frame.origin = self.tableViewOrigin!
            self.responseSearchTableView.isHidden = false
            self.btnShowList.isHidden = true
        })
    }
    
    func loadIndicator(isHidden: Bool) {
        indicator.isHidden = isHidden
        if isHidden == false {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
    @IBAction func btnActionTopographic(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Topographic") as! PopupTopographicViewController
//        self.addChild(vc)
//        vc.view.frame = self.view.frame
//        self.view.addSubview(vc.view)
//        vc.didMove(toParent: self)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    private func setMyGroup(_ searchPlace: String) {
        myGroup.notify(queue: DispatchQueue.main) {
            self.loadIndicator(isHidden: true)
            if self.arrPlace.count > 1 {
                
                self.responseSearchTableView.reloadData()
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.responseSearchTableView.alpha = 1
                }, completion: { _ in
                    self.responseSearchTableView.isHidden = false
                })
                
            } else {
                let locationSearch = CLLocationCoordinate2D(latitude: (self.arrPlace[0].geometry?.location?.lat ?? 21.001218), longitude: (self.arrPlace[0].geometry?.location?.lng ?? 105.800716))
                let marker = GMSMarker(position: locationSearch)
                marker.icon = GMSMarker.markerImage(with: .red)
                marker.title = searchPlace
                marker.map = self.mapView
                self.forcusLocation(locationSearch, zoom: 10)
                
                let bounds = GMSCoordinateBounds(coordinate: self.locationUser!, coordinate: locationSearch)
                let camera = self.mapView.camera(for: bounds, insets: UIEdgeInsets())!
                self.mapView.camera = camera
                
                self.path.add(self.locationUser!)
                self.path.add(locationSearch)
                let polyline = GMSPolyline(path: self.path)
                polyline.strokeColor = .blue
                
                polyline.map = self.mapView
            }
            
        }
    }
    
    @IBAction private func btnActionSearch(_ sender: Any) {
        let searchPlace = textFieldSearch.text!
        
        if !searchPlace.isEmpty {
            self.mapView.clear()
            getDataAPI(searchPlace: searchPlace, location: locationUser!)
            setMyGroup(searchPlace)
            
        }
    }
    
}

//MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if checkShow == false {
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                self.viewSearch.alpha = 0
                self.responseSearchTableView.alpha = 0
                self.btnShowList.alpha = 0
            }, completion: { _ in
                self.viewSearch.isHidden = true
                self.responseSearchTableView.isHidden = true
                self.btnShowList.isHidden = true
                mapView.settings.myLocationButton = false
                UIApplication.shared.isStatusBarHidden = true
                self.changedLocationBtn()
            })
            
            checkShow = true
            
        } else {
            if arrPlace.count > 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.btnShowList.alpha = 1 // Here you will get the animation you want
                }, completion: { _ in
                    self.btnShowList.isHidden = false
                    self.changedLocationBtn()
                })
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                self.viewSearch.alpha = 1
                self.responseSearchTableView.alpha = 1
            }, completion: { _ in
                self.viewSearch.isHidden = false // Here you hide it when animation done
                self.responseSearchTableView.isHidden = true
                mapView.settings.myLocationButton = true
                UIApplication.shared.isStatusBarHidden = false
            })
            
            checkShow = false
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
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
            mapView.isMyLocationEnabled = true
        @unknown default:
            fatalError()
        }
    }
}

//MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = responseSearchTableView.contentOffset
//
//        if let startOffset = self.defaultOffSet {
//            print("\(offset.y) ----- \(startOffset.y)")
//            if offset.y < startOffset.y {
//                print("down")
//                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
//                    self.responseSearchTableView.alpha = 0
//                    self.btnShowList.alpha = 1
//                }) { _ in
//                    self.responseSearchTableView.isHidden = true
//                    self.btnShowList.isHidden = false
//                }
//                let deltaY = fabs(startOffset.y - offset.y)
//                heightTableView.constant = heightTableView.constant - deltaY
//                heightTableView.constant -= 50
//            } else {
//                print("up")
//                let deltaY = fabs(startOffset.y - offset.y)
//                heightTableView.constant = heightTableView.constant + deltaY
//                heightTableView.constant += 50
//            }
    
            self.view.layoutIfNeeded()
//        }
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if(velocity.y>0){
//            NSLog("dragging Up");
//        }else{
//            NSLog("dragging Down");
//            self.heightTableView.constant -= 100
//            self.view.setNeedsLayout()
//        }
//    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = responseSearchTableView.dequeueReusableCell(withIdentifier: ListSearchTableViewCell.name, for: indexPath) as? ListSearchTableViewCell else {
            return UITableViewCell()
        }
        
        cell.fillData(placeModel: arrPlace[indexPath.row])
        if let photo = arrPlace[indexPath.row].photos?.first?.photo_reference {
            cell.dataPhotos(photo: getDataPlacePhoto(photoReference: photo))
            
        }
        let locationSearch = CLLocationCoordinate2D(latitude: (self.arrPlace[indexPath.row].geometry?.location!.lat)!, longitude: (self.arrPlace[indexPath.row].geometry?.location!.lng)!)
        let marker = GMSMarker(position: locationSearch)
        guard let str = arrPlace[indexPath.row].icon,
                   let url = URL(string: str),
                   let data = try? Data(contentsOf: url),
                    let imageIcon = UIImage(data: data) else {return cell}
        
        marker.icon = self.imageWithImage(image: imageIcon, scaledToSize: CGSize(width: 20.0, height: 20.0))
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        imageView.image = imageIcon
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        view.backgroundColor = .lightGray
//        view.layer.cornerRadius = view.layer.frame.size.width / 2
//        view.addSubview(imageView)
//        marker.iconView = view
        marker.title = arrPlace[indexPath.row].name
        marker.map = self.mapView
        
        return cell
        
    }
}

//MARK: - GMSAutocompleteViewControllerDelegate

extension ViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)

    }
}


