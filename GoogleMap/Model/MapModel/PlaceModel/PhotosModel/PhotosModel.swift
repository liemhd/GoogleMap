//
//  PhotosModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct PhotosModel: Mappable {
    var height: Int?
    var html_attributions: [String]?
    var photo_reference: String?
    var width: Int?
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        height <- map["height"]
        html_attributions <- map["html_attributions"]
        photo_reference <- map["photo_reference"]
        width <- map["width"]
    }
}
