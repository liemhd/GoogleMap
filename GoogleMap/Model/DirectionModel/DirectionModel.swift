//
//  DirectionModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct DirectionModel: Mappable {
    
    var geocoded_waypoints: [GeocodedWaypointsModel]?
    var routes: [RountesModel]?
    var status: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        geocoded_waypoints <- map["geocoded_waypoints"]
        routes <- map["routes"]
        status <- map["status"]
    }
}
