//
//  JSONDecoder+ConvertSnakeCase.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

extension JSONDecoder {
    public static func makeConvertFromSnakeCaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }
}

