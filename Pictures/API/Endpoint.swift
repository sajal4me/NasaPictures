//
//  Endpoint.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal protocol Endpoint {
    
    var scheme: String { get }
    
    var baseURL: String { get }
    
    var path: String { get }
    
    var parameters: [URLQueryItem] { get }
    
    var method: String { get }
}
