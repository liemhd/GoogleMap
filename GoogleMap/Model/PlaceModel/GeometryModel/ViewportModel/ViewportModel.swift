//
//  ViewportModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct ViewportModel: Mappable {
    var northeast: LocationModel?
    var southwest: LocationModel?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        northeast <- map["northeast"]
        southwest <- map["southwest"]
    }
}
