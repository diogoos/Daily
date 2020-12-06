//
//  JSONExtension.swift
//  Daily
//
//  Created by Diogo Silva on 11/13/20.
//

import Foundation

extension JSONDecoder {
    enum DecodingStrategy {
        case standard
        case compatible
    }

    static func withStrategy(_ d: DecodingStrategy) -> JSONDecoder {
        switch d {
        case .standard:
            return JSONDecoder()

        case .compatible:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }
    }
}


extension JSONEncoder {
    enum EncodingStrategy {
        case standard
        case compatible
    }

    static func withStrategy(_ d: EncodingStrategy) -> JSONEncoder {
        switch d {
        case .standard:
            return JSONEncoder()
        case .compatible:
            let decoder = JSONEncoder()
            decoder.keyEncodingStrategy = .convertToSnakeCase
            decoder.dateEncodingStrategy = .iso8601
            return decoder
        }
    }
}
