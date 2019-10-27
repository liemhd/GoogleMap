//
//  PlusCodeModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct PlusCodeModel: Mappable {
    var compound_code: String?
    var global_code: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        compound_code <- map["compound_code"]
        global_code <- map["global_code"]
    }
}
