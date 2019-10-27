//
//  DataModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct DataModel: Mappable {
    
    var html_attributions: [String]?
    var next_page_token: String?
    var results: [PlaceModel]?
    var status: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        html_attributions <- map["html_attributions"]
        next_page_token <- map["next_page_token"]
        results <- map["results"]
        status <- map["status"]
    }
}
