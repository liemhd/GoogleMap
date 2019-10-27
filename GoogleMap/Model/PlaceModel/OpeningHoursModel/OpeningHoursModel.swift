//
//  OpeningHoursModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct OpeningHoursModel: Mappable {
    var open_now: Bool?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        open_now <- map["open_now"]
    }
}
