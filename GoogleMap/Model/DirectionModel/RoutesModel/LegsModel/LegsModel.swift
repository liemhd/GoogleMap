//
//  LegsModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct LegsModel: Mappable {
    
    var distance: DistanceModel?
    var duration: DistanceModel?
    var end_address: String?
    var end_location: NortheastModel?
    var start_address: String?
    var start_location: NortheastModel?
    var steps: [StepsModel]?
    var traffic_speed_entry: [Any]?
    var via_waypoint: [Any]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        distance <- map["distance"]
        duration <- map["duration"]
        end_address <- map["end_address"]
        end_location <- map["end_location"]
        start_address <- map["start_address"]
        start_location <- map["start_location"]
        steps <- map["steps"]
        traffic_speed_entry <- map["traffic_speed_entry"]
        via_waypoint <- map["via_waypoint"]
    }
}
