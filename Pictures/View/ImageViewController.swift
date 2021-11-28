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
        viewModel.getFormattedStartDate(formattedStartDate: { [startDateTextField] date in
                startDateTextField?.text = date
            })
            startDateTextField.delegate = self
        }
    }
    @IBOutlet private weak var endDateTextField: UITextField! {
        didSet {
              viewModel.getFormattedEndtDate(formattedEndDate: { [endDateTextField] date in
                      endDateTextField?.text = date
            })
            endDateTextField.delegate = self
        }
    }
    
    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.hidesWhenStopped = true
            loader.startAnimating()
        }
    }
    @IBAction func favouriteBarBtnTapped(_ sender: UIBarButtonItem) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FavouriteListViewController") as? FavouriteListViewController else { return }
        navigationController?.pushViewController(viewController, animated: true)
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
            
            cell?.favouriteButtonTapped = { [weak self] isSelectedFavourite in
                self?.viewModel.update(favourite: imageModel, isSelected: isSelectedFavourite)
            }
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
        let itemCount = isPhone ? 2 : 3
        let item = NSCollectionLayoutItem(layoutSize: size)
          item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .fixed(4), trailing: .fixed(10), bottom: .fixed(4))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        return section
      })
    }
    
    // Apply snapshot changes to data source
    private func applySnapshot() {
        
        viewModel.getImage { [weak self] models in
            var newSnapshot = NSDiffableDataSourceSnapshot<Section, ImageModel>()
        
            newSnapshot.appendSections([.main])
            newSnapshot.appendItems(models)
            self?.dataSource.apply(newSnapshot, animatingDifferences: true) { [weak self] in
                self?.setupEmptyDataState(isEmpty: newSnapshot.numberOfItems == 0 )
            }
        }

    }
    
    // bind data to UI
    private func bindUI() {
        viewModel.didUpdateModel =  { [weak self] in
            guard let self = self else { return }
            self.applySnapshot()
            self.loader.stopAnimating()
        }
        
        viewModel.didGetError =  { [weak self] error in
            guard let self = self else { return }
            self.loader.stopAnimating()
            self.showAlert(message: error.errorDescription, cancelTrigger: { [weak self] in
                self?.dismiss(animated: true)
            }, reloadTrigger: { [weak self] in
                self?.viewModel.fetchPictures()
            })
        }
    }
   
    private func setupEmptyDataState(isEmpty: Bool) {
       // if isEmpty true then set the empty label otherwise reset collectionView.backgroundView to nil
        guard isEmpty else {
            collectionView.backgroundView = nil
            return
        }
        let label = UILabel(frame: CGRect(x: 12, y: 12, width: 100, height: 100))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No Data Available please select any other dates"
        collectionView.backgroundView = label
    }
}

// MARK: - UITextFieldDelegate methods

extension ImageViewController: UITextFieldDelegate {
    
    internal func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        guard let minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date()) else { return false }
        let isStartDateTextFieldSelected = textField === self.startDateTextField
        var selectedDate = Date()
        if isStartDateTextFieldSelected {
            viewModel.getStartDate { date in
                selectedDate = date
            }
        } else {
            viewModel.getEndDate { date in
                selectedDate = date
            }
        }
       
        
        DatePicker.openDatePickerIn(textField, outPutFormat: viewModel.getDateFormat, mode: .date, minimumDate: minimumDate, selectedDate: selectedDate) { [weak self] dateInString, date in
            guard let self = self else { return }
            self.loader.startAnimating()
            textField.text = dateInString
            if isStartDateTextFieldSelected && selectedDate != date {
                self.viewModel.updateStartDate(date)
            } else if selectedDate != date {
                self.viewModel.updateEndDate(date)
            }
        }
        
        return true
    }
    
    
    func showAlert(title: String? = "Error", message: String? = nil, cancelTrigger: @escaping () -> Void, reloadTrigger: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            cancelTrigger()
        }))
        
        alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { _ in
            reloadTrigger()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
