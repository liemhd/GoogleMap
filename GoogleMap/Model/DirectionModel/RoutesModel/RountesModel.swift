//
//  RountesModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct RountesModel: Mappable {
    
    var bounds: BoundsModel?
    var copyrights: String?
    var legs: [LegsModel]?
    var overview_polyline: OverviewPolylineModel?
    var summary: String?
    var warnings: [Any]?
    var waypoint_order: [Any]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        bounds <- map["bounds"]
        copyrights <- map["copyrights"]
        legs <- map["legs"]
        overview_polyline <- map["overview_polyline"]
        summary <- map["summary"]
        warnings <- map["warnings"]
        waypoint_order <- map["waypoint_order"]
    }
}
