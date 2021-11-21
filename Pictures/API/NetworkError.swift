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
    case custom(Error)
   
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
        case .custom:
            return "Error"
        }
    }
}

extension NetworkError: LocalizedError {
    internal var errorDescription: String? {
        message
    }
}
