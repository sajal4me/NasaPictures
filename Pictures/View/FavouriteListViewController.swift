//
//  FavouriteListViewController.swift
//  Pictures
//
//  Created by Sajal Gupta on 27/11/21.
//

import UIKit

internal final class FavouriteListViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private let viewModel: FavouriteListViewModel
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ImageModel> = UICollectionViewDiffableDataSource<Section, ImageModel>(
        collectionView: self.collectionView,
        cellProvider: { (collectionView, indexPath, imageModel) ->
            UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PictureCell.cellIdentifier,
                for: indexPath) as? PictureCell else { return nil }
            
            cell.model = imageModel
            cell.disableFavouriteButton()
            return cell
        }
    )
    
    internal enum Section {
        case main
    }
    
    // MARK: - Initializer
    
    internal required init?(coder aDecoder: NSCoder) {
        viewModel = FavouriteListViewModel()
        super.init(coder: aDecoder)
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favourite Pictures"
        registertCell()
        configureLayout()
        applySnapshot()
    }
    
    
    private func registertCell() {
        collectionView.register(UINib(nibName: PictureCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: PictureCell.cellIdentifier)
    }
    //  collectionview layout configuration
    private func configureLayout() {
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(600)
            )
            let itemCount = isPhone ? 2 : 3
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.interGroupSpacing = 10
            return section
        })
    }
    
    // Apply snapshot changes to data source
    private func applySnapshot() {
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, ImageModel>()
        
        newSnapshot.appendSections([.main])
        viewModel.model(completion: { [weak self] images in
            newSnapshot.appendItems(images)
            self?.dataSource.apply(newSnapshot, animatingDifferences: false) { [weak self] in
                self?.setupEmptyDataState(isEmpty: newSnapshot.numberOfItems == 0 )
            }
        })
    }
    
    private func setupEmptyDataState(isEmpty: Bool) {
        // if isEmpty true then set the empty label otherwise reset collectionView.backgroundView to nil
        guard isEmpty else {
            collectionView.backgroundView = nil
            return
        }
        let label = UILabel(frame: CGRect(x: 12, y: 12, width: view.frame.width-50, height: 100))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No Favourite image are available please add images to your favourite list!"
        collectionView.backgroundView = label
    }
}
