//
//  ImageViewController.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import UIKit

internal final class ImageViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var startDateTextField: UITextField! {
        didSet {
            startDateTextField.text = viewModel.getFormattedStartDate
            startDateTextField.delegate = self
        }
    }
    @IBOutlet private weak var endDateTextField: UITextField! {
        didSet {
            endDateTextField.text = viewModel.getFormattedEndtDate
            endDateTextField.delegate = self
        }
    }
    
    // MARK: Private Properties
    
    private let viewModel: ImageViewModel
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ImageModel> = UICollectionViewDiffableDataSource<Section, ImageModel>(
        collectionView: self.collectionView,
        cellProvider: { (collectionView, indexPath, imageModel) ->
            UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PictureCell.cellIdentifier,
                for: indexPath) as? PictureCell
            cell?.model = imageModel
            return cell
        }
    )
    
   // Section enum used to setup DiffableDataSource
    internal enum Section {
        case main
    }
    
    // MARK: - Initializer

    internal required init?(coder aDecoder: NSCoder) {
        viewModel = ImageViewModel()
        super.init(coder: aDecoder)
    }
    
    // MARK: - Life-cycle methods
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
       
        registertCell()
        configureLayout()
        applySnapshot(animatingDifferences: false)
        
        bindUI()
    }
    
    // MARK: - private methods
    
    private func registertCell() {
        collectionView.register(UINib(nibName: PictureCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: PictureCell.cellIdentifier)
    }
    //  collectionview layout configuration
    private func configureLayout() {
        
      collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
        let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        let size = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(300)
        )
        let itemCount = isPhone ? 2 : 6
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        return section
      })
    }
    
    // Apply snapshot changes to data source
    private func applySnapshot(animatingDifferences: Bool = true) {
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, ImageModel>()
        newSnapshot.appendSections([.main])
        newSnapshot.appendItems(viewModel.model)
        
        
        dataSource.apply(newSnapshot, animatingDifferences: animatingDifferences)
    }
    
    // bind data to UI
    private func bindUI() {
        viewModel.didUpdateModel =  { [weak self] in
            print("viewModel.model.count \(self!.viewModel.model.count)")
            self?.applySnapshot()
        }
    }
}

// MARK: - UITextFieldDelegate methods

extension ImageViewController: UITextFieldDelegate {
    
    internal func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        guard let minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date()) else { return false }
        let isStartDateTextFieldSelected = textField === self.startDateTextField
        let selectedDate = isStartDateTextFieldSelected ? viewModel.getStartDate : viewModel.getEndDate
        
        DatePicker.openDatePickerIn(textField, outPutFormat: viewModel.getDateFormat, mode: .date, minimumDate: minimumDate, selectedDate: selectedDate) { [weak self] dateInString, date in
            guard let self = self else { return }

            textField.text = dateInString
            if isStartDateTextFieldSelected && selectedDate != date {
                self.viewModel.updateStartDate(date)
            } else if selectedDate != date {
                self.viewModel.updateEndDate(date)
            }
        }
        
        return true
    }
}
