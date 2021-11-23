//
//  NasaUsecase.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal protocol UsecaseProtocol {
    func fetchPictureOfDay(startDate: String, endDate: String)
}

protocol UsecaseDelegate: AnyObject {
    func didLoad(result: Result<[ImageModel], NetworkError>)
}


internal final class NasaUsecase: UsecaseProtocol {
    private let networkProvider = Networking()
    internal weak var delegate: UsecaseDelegate?
    
    internal func fetchPictureOfDay(startDate: String, endDate: String) {
        
        networkProvider.request(endpoint: NasaTarget.aopd(startDate: startDate, endDate: endDate)) { [weak self] result in
            self?.delegate?.didLoad(result: result)
        }
    }
}
