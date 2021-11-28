//
//  Transferrable.swift
//  Pictures
//
//  Created by Sajal Gupta on 27/11/21.
//

import Foundation

internal protocol Transferrable {
  associatedtype S
  func transfer() -> S
}
