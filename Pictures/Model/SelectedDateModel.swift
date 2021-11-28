//
//  SelectedDateModel.swift
//  Pictures
//
//  Created by Sajal Gupta on 23/11/21.
//

import Foundation
import RealmSwift

// It is used to store the stat date and end date into the  realm db
internal final class SelectedDateModel: Object, Transferrable {
    
    typealias S = SelectedDateModel
        
        internal func transfer() -> S {
            return self
        }
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    @Persisted(primaryKey: true) var id: Int
    
    convenience internal init(startDate: Date, endDate: Date) {
        self.init()
        self.id = 1
        self.startDate = startDate
        self.endDate = endDate
    }
}

