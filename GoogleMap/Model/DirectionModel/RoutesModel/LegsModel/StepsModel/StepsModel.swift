//
//  StepsModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct StepsModel: Mappable {
    
    var distance: DistanceModel?
    var duration: DistanceModel?
    var end_location: NortheastModel?
    var html_instructions: String?
    var polyline: PolylineModel?
    var start_location: NortheastModel?
    var travel_mode: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        distance <- map["distance"]
        duration <- map["duration"]
        end_location <- map["end_location"]
        html_instructions <- map["html_instructions"]
        polyline <- map["polyline"]
        start_location <- map["start_location"]
        travel_mode <- map["travel_mode"]
    }
}
