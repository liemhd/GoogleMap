//
//  NortheastModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct NortheastModel: Mappable {
    
    var lat: Double?
    var lng: Double?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
    }
}
