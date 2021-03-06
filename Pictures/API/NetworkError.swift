//
//  NetworkError.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal enum NetworkError: Error, Equatable {
    case noInternet
    case pageNotFound
    case underMaintenance
    case invalidURL
    case decodableFail
    case custom(String)
   
    internal var message: String {
        switch self {
        case .noInternet:
            return "Please try again !."
        case .pageNotFound:
            return "Please try again !."
        case .underMaintenance:
            return "Please try again !."
        case .invalidURL:
            return "We are not able to create the url, seems you have put wring parameter"
        case .decodableFail:
            return "Decoading fail any non optional key is missing in response"
        case let .custom(errorMessage):
            return errorMessage
        }
    }
}

extension NetworkError: LocalizedError {
    internal var errorDescription: String? {
        message
    }
}
