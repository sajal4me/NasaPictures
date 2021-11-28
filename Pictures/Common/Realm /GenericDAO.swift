//
//  GenericDAO.swift
//  Pictures
//
//  Created by Sajal Gupta on 27/11/21.
//

import Foundation
import RealmSwift

//A common GenericDAO class to access ream db
//
// Usage
//
//Once we have created our objects, all we need to do is call the genericDao implementation:
//
//let animalDAO = GenericDAO<Animal>()
// where Animal is realm model

internal final class GenericDAO<T>:GenericDAOProtocol where T:Object, T:Transferrable {
    
    
    //  MARK: setup
    internal let background = { (block: @escaping () -> Void) in
        DispatchQueue.main.async (execute: block)
    }
        
    //   MARK: protocol implementation
    
    internal var realm: Realm? {
        get {
            return try? Realm()
        }
    }
    
    internal func save(_ object: T, completion: ((_ : Bool) -> Void)? ) {
        background {
            do {
                guard let realm = self.realm else {
                    completion?(false)
                    return
                }
                try realm.write {
                    realm.add(object, update: .modified)
                }
            } catch {
                completion?(false)
            }
            completion?(true)
        }
    }
    
    internal func saveAutoincrement<T>(_ object: T, completion: @escaping (Bool) -> ()) where T:Object, T:Transferrable, T:Autoincrement {
        background {
            guard let realm = self.realm else {
                completion(false)
                return
            }
            
            do {
                let maxID = (realm.objects(T.self).max(ofProperty: "id") as Int? ?? 0) + 1
                object.setValue(maxID, forKey: "id")
                
                try realm.write {
                    realm.add(object)
                }
            } catch {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    internal func saveAll(_ objects: [T], completion: @escaping (_ : Int) -> () ){
        background {
            var count = 0
            guard let realm = self.realm else { completion(count); return }
            for obj in objects {
                do {
                    try realm.write {
                        // for every object added, increment counter
                        realm.add(obj, update: .modified)
                        count += 1
                    }
                } catch {
                }
            }
            // send counter to completion
            completion(count)
        }
    }
    
    private func findAllResults(predicate: NSPredicate?) -> Results<T>? {
        guard let predicate = predicate else {
            return realm?.objects(T.self)
        }
        return realm?.objects(T.self).filter(predicate)
        
        
    }
    
    internal func findAll(sortedKeyPath: String?, predicate: NSPredicate?, completion: @escaping ([T.S]) -> () ) {
        background {
            // parse the Realm Results into array
            guard let res = self.findAllResults(predicate: predicate) else { completion([]); return }
            if let ketPath = sortedKeyPath {
                let soretedResult = res.sorted(byKeyPath: ketPath)
                completion(Array(soretedResult).map {$0.transfer()} )
            }
            
            completion(Array(res).map {$0.transfer()} )
            
        }
    }
    
    internal func findByPrimaryKey(_ id: Any, completion: @escaping (T.S?) -> Void ){
        background {
            completion(self.realm?.object(ofType: T.self, forPrimaryKey: id)?.transfer())
        }
    }
    
    internal func deleteAll(completion: @escaping (_ : Bool) -> () ) {
        background {
            guard let res = self.findAllResults(predicate: nil),
                  let realm = self.realm else {
                      //    logger.error("No realm")
                      completion(false)
                      return
                  }
            
            do {
                try realm.write {
                    realm.delete(res)
                    completion(true)
                }
            } catch {
                //logger.error("error deleting movies")
                completion(false)
            }
        }
    }
    
    internal func resolve(_ ref : ThreadSafeReference<T>) -> T? {
        let realm = try! Realm()
        return realm.resolve(ref)
    }
    
}

