//
//  GeocodedWaypointsModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct GeocodedWaypointsModel: Mappable {
    
    var geocoder_status: String?
    var place_id: String?
    var types: [String]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        geocoder_status <- map["geocoder_status"]
        place_id <- map["place_id"]
        types <- map["types"]
    }
}
