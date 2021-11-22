//
//  ImageModel.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal struct ImageModel: Decodable, Hashable {
    internal let id: UUID
    internal let copyright: String?
    internal let date: String?
    internal let explanation: String?
    internal let hdurl: URL?
    internal let mediaType: String?
    internal let serviceVersion: String?
    internal let title: String?
    internal let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case copyright
        case date
        case explanation
        case hdurl
        case mediaType
        case serviceVersion
        case title
        case url
        case id
    }
    
}

extension ImageModel {
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        explanation = try container.decodeIfPresent(String.self, forKey: .explanation)
        hdurl = try container.decodeIfPresent(URL.self, forKey: .hdurl)
        mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
        serviceVersion = try container.decodeIfPresent(String.self, forKey: .serviceVersion)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    }
}
