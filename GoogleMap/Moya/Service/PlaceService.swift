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
    case placeSearch(search: String)
    case placeSearchWithLocation(searchPlace: String, location: CLLocationCoordinate2D)
    case placePhoto(photoReference: String)
    case directions(origin: String, destination: String, avoid: String)
}

extension PlaceService: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Constants.baseUrl) else {
            fatalError()
        }
        
        return url
    }
    
    var path: String {
        switch self {
        case .placeSearchWithLocation(_,_), .placeSearch(_):
            return Constants.placeSearch
        case .placePhoto(_):
            return Constants.placePhoto
        case .directions(_,_,_):
            return Constants.directions
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
        case .placeSearchWithLocation(let searchPlace, let location):
            let parameters = ["radius": "500m",
                                "query": "\(searchPlace)",
                                "location": "\(location)",
                                "key": Constants.KEY_MAP]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .placePhoto(let photoReference):
            let parameters = ["photoreference": "\(photoReference)",
                                "maxwidth": "400",
                                "key": Constants.KEY_MAP]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .directions(let origin, let destination, let avoid):
            let parameters = ["origin": "\(origin)",
                                "destination": "\(destination)",
                                "avoid":"\(avoid)",
                                "key": Constants.KEY_DIRECTIONS]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .placeSearch(let searchPlace):
            let parameters = ["query": "\(searchPlace)",
                                "key": Constants.KEY_MAP]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return Constants.headers
    }
}

