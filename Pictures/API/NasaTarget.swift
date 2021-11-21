//
//  NasaTarget.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal enum NasaTarget {
    
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
        return "/planetary/apod"
    }
    
    var parameters: [URLQueryItem] {
        return []
    }
    
    var method: String {
        return Method.get.rawValue
    }
}
