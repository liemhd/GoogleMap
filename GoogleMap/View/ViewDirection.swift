//
//  ViewDirection.swift
//  GoogleMap
//
//  Created by Duy Liêm on 1/13/20.
//  Copyright © 2020 DuyLiem. All rights reserved.
//

import UIKit

protocol DirectionDelegate {
    func removeView()
}

final class ViewDirection: UIView {
    //MARK: - Outlet
    @IBOutlet weak var textFieldYourLocation: UITextField!
    @IBOutlet weak var textFieldLocationSearch: UITextField!
    @IBOutlet weak var collectionViewTypeExpediency: UICollectionView!
    
    //MARK: - Properties
    private var arrExpediency:[UIImage] = []
    var directionDelegate: DirectionDelegate?
    
    override func awakeFromNib() {
        configCollectionView()
        configView()
    }
    
    //MARK: - Function
    private func configView() {
        dropShadow(view: self)
//        self.dropShadow(color: .black, opacity: 0.3, offSet: CGSize.zero, radius: 2, scale: true)
    }
    
    private func configCollectionView() {
        collectionViewTypeExpediency.delegate = self
        collectionViewTypeExpediency.dataSource = self
        collectionViewTypeExpediency.register(UINib(nibName: TypeExpediencyCollectionViewCell.name, bundle: nil), forCellWithReuseIdentifier: TypeExpediencyCollectionViewCell.name)
        
        arrExpediency = [#imageLiteral(resourceName: "imv_car"), #imageLiteral(resourceName: "imv_motobike"), #imageLiteral(resourceName: "imv_train"), #imageLiteral(resourceName: "imv_walk"),#imageLiteral(resourceName: "imv_airplane")]
    }
    
    func fillTextSearch(text: String) {
        textFieldLocationSearch.text = text
    }

    //MARK: - Action
    @IBAction func backBtnAction(_ sender: UIButton) {
        directionDelegate?.removeView()
    }
    
    @IBAction func reseverBtnAction(_ sender: UIButton) {
    }
    @IBAction func moreBtnAction(_ sender: UIButton) {
    }
}

//MARK: - UICollectionViewDataSource
extension ViewDirection: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrExpediency.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeExpediencyCollectionViewCell.name, for: indexPath) as? TypeExpediencyCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.fillData(time: "time", image: arrExpediency[indexPath.row])
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ViewDirection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = "Time"
        let image = arrExpediency[indexPath.row]
        let widthText = text.size(withAttributes:[.font: UIFont.systemFont(ofSize:11.0)]).width
        let widthImage = image.size.width
        
        return CGSize(width: /*widthText + widthImage + 16*/ self.frame.width / 5, height: 20.0)
    }
}
