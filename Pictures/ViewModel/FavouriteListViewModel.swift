//
//  FavouriteListViewModel.swift
//  Pictures
//
//  Created by Sajal Gupta on 27/11/21.
//

import Foundation

internal final class FavouriteListViewModel {
    
    private let dbManager: GenericDAO<ImageModel>
    
    internal init(dBManager: GenericDAO<ImageModel> = GenericDAO<ImageModel>()) {
        self.dbManager = dBManager
    }
    
    // fetch models from realm db that has isFavourite key true
    internal func model(completion: @escaping ([ImageModel]) -> Void) {
        let predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))
        dbManager.findAll(sortedKeyPath: "date", predicate: predicate) { images in
            completion(images)
        }
    }
    
}
