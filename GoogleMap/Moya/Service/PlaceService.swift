//
//  PlaceService.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/17/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import Moya
import CoreLocation


enum PlaceService {
    case placeSearch(searchPlace: String, location: CLLocationCoordinate2D)
    case placePhoto(photoReference: String)
}

extension PlaceService: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place") else {
            fatalError()
        }
        return url
    }
    
    var path: String {
        switch self {
        case .placeSearch(_,_):
            return "/textsearch/json"
        case .placePhoto(_):
            return "/photo"
        }
        
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .placeSearch(let searchPlace, let location):
            let parameters = ["radius": "500m",
                              "query": "\(searchPlace)",
                              "location": "\(location)",
                              "key": KEY]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .placePhoto(let photoReference):
            let parameters = ["photoreference": "\(photoReference)",
                                "maxwidth": "400",
                                "key": KEY]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}

