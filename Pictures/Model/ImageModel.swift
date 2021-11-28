//
//  ImageModel.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation
import RealmSwift

internal final class ImageModel: Object, Decodable, Transferrable {
    
    typealias S = ImageModel
    
    internal func transfer() -> S {
        return self
    }
    
    @Persisted var url: String
    @Persisted var copyright: String?
    @Persisted(primaryKey: true) var date: String
    @Persisted var explanation: String?
    @Persisted var hdurl: String?
    @Persisted var mediaType: String?
    @Persisted var serviceVersion: String?
    @Persisted var title: String?
    @Persisted var isFavourite: Bool?
    
}
