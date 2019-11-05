//
//  BoundsModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct BoundsModel: Mappable {
    
    var northeast: NortheastModel?
    var southwest: NortheastModel?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        northeast <- map["northeast"]
        southwest <- map["southwest"]
    }
}
