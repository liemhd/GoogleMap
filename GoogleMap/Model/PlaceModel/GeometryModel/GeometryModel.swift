//
//  GeometryModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct GeometryModel: Mappable {
    var location: LocationModel?
    var viewport: ViewportModel?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        location <- map["location"]
        viewport <- map["viewport"]
    }
}
