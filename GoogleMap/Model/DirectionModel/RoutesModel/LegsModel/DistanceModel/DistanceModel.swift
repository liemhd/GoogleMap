//
//  DistanceModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct DistanceModel: Mappable {
    
    var text: String?
    var value: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        text <- map["text"]
        value <- map["value"]
    }
}
