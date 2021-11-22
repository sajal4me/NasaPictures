//
//  NasaTarget.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal enum NasaTarget {
    case aopd(startDate: String, endDate: String)
}

extension NasaTarget: Endpoint {
    enum Method: String {
        case get = "GET"
    }
    
    var scheme: String {
        return "https"
    }
    
    var baseURL: String{
        return "api.nasa.gov"
    }
    
    var path: String {
        switch self {
        case .aopd:
            return "/planetary/apod"
        }
        
    }
    
    var parameters: [URLQueryItem] {
        let param: [String: String]
        switch self {
        case let .aopd(startDate, endDate):
            param = [
                "api_key": "via0baxs40qdl0PgFX2woO3leb3aOkBYBoTMXsEx",
                "start_date": startDate,
                "end_date": endDate
            ]
        }
        return param.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
    }
    
    var method: String {
        switch self {
        case .aopd:
            return Method.get.rawValue
        }
    }
}
