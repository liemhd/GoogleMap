//
//  PolylineModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct PolylineModel: Mappable {
    
    var points: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        points <- map["points"]
    }
}
