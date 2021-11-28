//
//  ImageViewModel.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal final class ImageViewModel {
    
    private var imageModelDBManager: GenericDAO<ImageModel>
    private var selectedDateModelDBManager: GenericDAO<SelectedDateModel>
    private let usecase: UsecaseProtocol
    private var imageModel: [ImageModel] = []
    private var selectedDateModel: SelectedDateModel?
    private let dateFormatter = DateFormatter()
    private let dateFormat = "yyyy-MM-dd"

    // closure to bind data
    internal var didUpdateModel: (() -> Void)?
    internal var didGetError: ((NetworkError) -> Void)?
    
    
    internal init(imageModelDBManager: GenericDAO<ImageModel> = GenericDAO<ImageModel>()) {
        self.imageModelDBManager = imageModelDBManager
        dateFormatter.dateFormat = dateFormat
        let nassaUsecase = NasaUsecase()
        self.usecase = nassaUsecase
        selectedDateModelDBManager = GenericDAO<SelectedDateModel>()
        selectedDateModelDBManager.findByPrimaryKey(1) { [weak self] model in
            if let model = model {
                self?.selectedDateModel = model
            } else {
                let model = SelectedDateModel(startDate: Date(), endDate: Date())
                self?.selectedDateModel = model
                self?.selectedDateModelDBManager.save(model, completion: nil)
            }
            
        }
        imageModelDBManager.findAll(sortedKeyPath: "date", predicate: nil, completion: { [weak self] models in
           self?.imageModel = models
       })
        
        nassaUsecase.delegate = self
        // load Picture from API
        self.fetchPictures()
    }
}


extension ImageViewModel: UsecaseDelegate {
    internal func didLoad(result: Result<[ImageModel], NetworkError>) {
        switch result {
            
        case let .success(model):
            
            imageModelDBManager.saveAll(model) { [weak self] isSaved in
                guard let self = self else { return }
                    self.didUpdateModel?()
            }
        case let .failure(error):
            didGetError?(error)
        }
    }
    
    internal func getImage(models data: @escaping ([ImageModel])-> Void)  {
        imageModelDBManager.findAll(sortedKeyPath: "date", predicate: nil) { imageModel in
                data(imageModel)
        }
    }
    
    internal func getStartDate(startDate: @escaping (Date) -> Void) {
        selectedDateModelDBManager.findByPrimaryKey(1) { model in
            startDate(model?.startDate ?? Date())
        }
    }
    
    internal func getFormattedStartDate(dateFormat: String = "yyyy-MM-dd", formattedStartDate: @escaping (String) -> Void) {
        dateFormatter.dateFormat = dateFormat
        getStartDate { [weak self] startDate in
            let startDate = self?.dateFormatter.string(from: startDate) ?? ""
            formattedStartDate(startDate)
        }
        
    }
    
    
    internal func getEndDate(endDate: @escaping (Date) -> Void) {
        selectedDateModelDBManager.findByPrimaryKey(1) { model in
            DispatchQueue.main.async {
                endDate(model?.endDate ?? Date())
            }
           
        }
    }
    
    internal func getFormattedEndtDate(dateFormat: String = "yyyy-MM-dd", formattedEndDate: @escaping (String) -> Void) {
        dateFormatter.dateFormat = dateFormat
        getEndDate { [weak self] endDate in
            let endDate = self?.dateFormatter.string(from: endDate) ?? ""
            formattedEndDate(endDate)
        }
        
    }
    internal var getDateFormat: String {
        dateFormat
    }
    

    internal func updateStartDate(_ newDate: Date) {
        
        // current selected date is same as newDate then no need to load data from API
        if selectedDateModel?.startDate == newDate { return }
        
        selectedDateModelDBManager.findByPrimaryKey(1) { [weak self] dateModel in
            guard let self = self, let model = dateModel else { return }
            let selectedDate = SelectedDateModel(startDate: newDate, endDate: model.endDate)
            self.selectedDateModelDBManager.save(selectedDate) { [weak self] _ in
                        self?.fetchPictures()
            }
        }
    }
    
    internal func updateEndDate(_ newDate: Date) {
        // current selected date is same as newDate then no need to load data from API
        if selectedDateModel?.endDate == newDate { return }

        selectedDateModelDBManager.findByPrimaryKey(1) { [weak self] dateModel in
            guard let self = self, let model = dateModel else { return }
            let selectedDate = SelectedDateModel(startDate: model.startDate, endDate: newDate)
            
            self.selectedDateModelDBManager.save(selectedDate) { [weak self] _ in
                        self?.fetchPictures()
            }
        }
    }
    
    internal func update(favourite model: ImageModel, isSelected: Bool) {
        imageModelDBManager.findByPrimaryKey(model.date) { [weak self] model in
            guard let model = model else { return }
            let image = ImageModel(value: model)
            image.isFavourite = isSelected
            
            self?.imageModelDBManager.save(image, completion: nil)
        }
    }
    
    // To fetch photo - remove all exisiting images from DB then add the updated image onto DB to prevent inconsistency
    internal func fetchPictures() {
        
        let dispatchGroup = DispatchGroup()
        
        var startDateInString: String = ""
        var endDateInString: String = ""
        
        dispatchGroup.enter()
        getFormattedStartDate { dateInString in
            startDateInString = dateInString
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        getFormattedEndtDate { dateInString in
            endDateInString = dateInString
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.usecase.fetchPictureOfDay(startDate: startDateInString, endDate: endDateInString)
        }
    }
}
