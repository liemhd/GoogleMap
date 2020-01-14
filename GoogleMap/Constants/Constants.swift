//
//  Constants.swift
//  GoogleMap
//
//  Created by Duy Liêm on 1/13/20.
//  Copyright © 2020 DuyLiem. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    public static let KEY_MAP = "AIzaSyDiVtNfYdQ1uZ9aGy7plaJ7Ff3J8xZ63rI"
    public static let KEY_ROADS = "AIzaSyBecR-RlTBLJi1_n-7Mr_Ydlhy7WzDfdLo"
    public static let KEY_DIRECTIONS = "AIzaSyB4K8NSK4hsNA7jfJ7SuqhIBMhUxOgcMZQ"
    
    public static let minimumLineSpacing: CGFloat = 2
    public static let minimumInteritemSpacing: CGFloat = 2
    public static let numberOfItems: CGFloat = 5
    public static let fullView: CGFloat = 70
    
    public static let yourLocation = "Your location"
    public static let empty = ""
    public static let dataOk = "OK"
    
    public static let baseUrl = "https://maps.googleapis.com/maps/api/"
    
    public static let placeSearch = "place/textsearch/json"
    public static let placePhoto = "place/photo"
    public static let directions = "directions/json"
    public static let headers = ["Content-Type": "application/json"]
}
