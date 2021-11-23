//
//  ImageViewModel.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal final class ImageViewModel {
    
    private let usecase: UsecaseProtocol
    private var imageModel: [ImageModel] = []
    private var startDate: Date = Date()
    private var endDate: Date = Date()
    private let dateFormatter = DateFormatter()
    private let dateFormat = "yyyy-MM-dd"
    
    // closure to bind data
    internal var didUpdateModel: (() -> Void)?
    internal var didGetError: ((NetworkError) -> Void)?
    
    internal init() {
        let nassaUsecase = NasaUsecase()
        self.usecase = nassaUsecase
        nassaUsecase.delegate = self
        
        dateFormatter.dateFormat = dateFormat
        
        // load Picture from API
        usecase.fetchPictureOfDay(startDate: getFormattedStartDate, endDate: getFormattedEndtDate)
    }
}


extension ImageViewModel: UsecaseDelegate {
    internal func didLoad(result: Result<[ImageModel], NetworkError>) {
        switch result {
            
        case let .success(model):
            imageModel = model
            didUpdateModel?()
            
        case let .failure(error):
            didGetError?(error)
        }
    }
    
    internal var model: [ImageModel] {
        imageModel
    }
    
    internal var getStartDate: Date {
        startDate
    }
    
    internal var getFormattedStartDate: String {
        dateFormatter.string(from: startDate)
    }
    
    internal var getEndDate: Date {
        endDate
    }
    
    internal var getFormattedEndtDate: String {
        dateFormatter.string(from: endDate)
    }
    
    internal var getDateFormat: String {
        dateFormat
    }
    internal func updateStartDate(_ newDate: Date) {
        // current selected date is same as newDate then no need to load data from API
        if startDate == newDate { return }
        startDate = newDate
        usecase.fetchPictureOfDay(startDate: getFormattedStartDate, endDate: getFormattedEndtDate)
    }
    
    internal func updateEndDate(_ newDate: Date) {
        // current selected date is same as newDate then no need to load data from API
        if endDate == newDate { return }
        endDate = newDate
        usecase.fetchPictureOfDay(startDate: getFormattedStartDate, endDate: getFormattedEndtDate)
    }
}
