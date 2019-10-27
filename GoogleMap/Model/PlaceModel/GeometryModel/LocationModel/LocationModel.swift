//
//  LocationModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

class LocationModel: Mappable {
    var lat: Double?
    var lng: Double?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
    }
}
