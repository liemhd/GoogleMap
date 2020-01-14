//
//  Extension + UIViewcontroller.swift
//  GoogleMap
//
//  Created by Duy Liêm on 11/1/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

extension UIViewController {
    func getDataPlacePhoto(photoReference: String) -> String {
        let dataPhotos = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(Constants.KEY_MAP)"
        
        return dataPhotos
    }
}
