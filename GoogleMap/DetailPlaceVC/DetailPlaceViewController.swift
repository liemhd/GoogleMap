//
//  DetailPlaceViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 11/1/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

final class DetailPlaceViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet private weak var detailPlaceTableView: UITableView!
    
    //MARK: - Properties
    var placeData: PlaceModel?
    var directionClosures: ((_ placeData: PlaceModel) -> Void)?
    
    //MARK: - View lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
    }
    
    //MARK: - Function
    private func configTableView() {
        detailPlaceTableView.delegate = self
        detailPlaceTableView.dataSource = self
        detailPlaceTableView.register(UINib(nibName: PhotoTableViewCell.name, bundle: nil), forCellReuseIdentifier: PhotoTableViewCell.name)
        detailPlaceTableView.register(UINib(nibName: TitleTableViewCell.name, bundle: nil), forCellReuseIdentifier: TitleTableViewCell.name)
        detailPlaceTableView.register(UINib(nibName: UtilityTableViewCell.name, bundle: nil), forCellReuseIdentifier: UtilityTableViewCell.name)
    }
    
    //MARK: - Action
    @IBAction func btnActionDismis(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDelegate
extension DetailPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return view.frame.size.height / 3
        default:
            return UITableView.automaticDimension
        }
    }
}

//MARK: - UITableViewDataSource
extension DetailPlaceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.name, for: indexPath) as? PhotoTableViewCell else {
                return UITableViewCell ()
                
            }
            guard let photo = placeData?.photos?.first?.photo_reference else { return cell }
            cell.image(imageStr: getDataPlacePhoto(photoReference: photo))
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.name, for: indexPath) as? TitleTableViewCell else {
                return UITableViewCell ()
                
            }
            guard let placeData = placeData else {return cell}
            cell.fillData(placeData: placeData)
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UtilityTableViewCell.name, for: indexPath) as? UtilityTableViewCell else {
                return UITableViewCell ()
                
            }
            cell.callBack = { [weak self] (type: Callback) in
                guard let wSelf = self else {return}
                switch type {
                case .direction:
                    guard let placeData = wSelf.placeData else {return}
                    wSelf.directionClosures?(placeData)
                    wSelf.dismiss(animated: true, completion: nil)
                    break
                case .gps:
                    print(type.hashValue)
                case .call:
                    print(type.hashValue)
                case .save:
                    print(type.hashValue)
                }
            }
            
            return cell
        default:
            return UITableViewCell ()
        }
    }
    
    
}
