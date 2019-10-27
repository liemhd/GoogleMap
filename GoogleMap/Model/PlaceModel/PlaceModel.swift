//
//  PlaceModel.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import ObjectMapper

struct PlaceModel: Mappable {
    var formatted_address: String?
    var geometry: GeometryModel?
    var icon: String?
    var id: String?
    var name: String?
    var opening_hours: OpeningHoursModel?
    var photos: [PhotosModel]?
    var place_id: String?
    var plus_code: PlusCodeModel?
    var rating: Double?
    var reference: String?
    var types: [String]?
    var user_ratings_total: Int?
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        formatted_address <- map["formatted_address"]
        geometry <- map["geometry"]
        icon <- map["icon"]
        id <- map["id"]
        name <- map["name"]
        opening_hours <- map["opening_hours"]
        photos <- map["photos"]
        place_id <- map["place_id"]
        plus_code <- map["plus_code"]
        rating <- map["rating"]
        reference <- map["reference"]
        types <- map["types"]
        user_ratings_total <- map["user_ratings_total"]
    }
}
