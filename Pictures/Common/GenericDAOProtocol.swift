//
//  GenericDAOProtocol.swift
//  Pictures
//
//  Created by Sajal Gupta on 27/11/21.
//

import Foundation
import RealmSwift


internal protocol GenericDAOProtocol {
    associatedtype T: Object, Transferrable
    associatedtype S = T.S
    
    var realm: Realm? { get }
    
    func save(_ object: T, completion: ((_ : Bool) -> Void)? )
    
    func saveAutoincrement<T>(_ object: T, completion: @escaping (Bool) -> Void) where T:Object, T:Transferrable, T:Autoincrement
    
    func saveAll(_ objects: [T], completion: @escaping (_ : Int) -> Void )
    
    func findAll(sortedKeyPath: String?, predicate: NSPredicate?, completion: @escaping (_ : [S]) -> Void )
    
    func findByPrimaryKey(_ id: Any, completion: @escaping (_ : S?) -> Void )
    
    func deleteAll(completion: @escaping (_ : Bool) -> Void )
    
    func resolve(_ ref : ThreadSafeReference<T>) -> T?
    
}

