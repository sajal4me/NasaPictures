//
//  PictureCell.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import UIKit
import Kingfisher

internal final class PictureCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var explanationLabel: UILabel!
    @IBOutlet private weak var favouriteButton: UIButton! {
        didSet {
            favouriteButton.setTitle("", for: .normal)
            favouriteButton.setImage(UIImage(named: "favourite"), for: .normal)
            favouriteButton.setImage(UIImage(named: "filled_favourite"), for: .selected)
        }
    }
    
    internal static var cellIdentifier: String {
        String(describing: self)
    }
    
    internal var favouriteButtonTapped: ((_ isSelectedFavourite: Bool)-> Void)?
    
    internal var model: ImageModel? {
        didSet {
            // show idicator in center while loading image from url
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: URL(string: model?.url ?? ""), placeholder: UIImage(named: "placeholder"))
            titleLabel.text = model?.title
            dateLabel.text = model?.date
            explanationLabel.text = model?.explanation
            favouriteButton.isSelected = model?.isFavourite ?? false
        }
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 8
    }
    
    @IBAction func favouriteButtonTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.favouriteButtonTapped?(sender.isSelected)
    }
    
    internal func disableFavouriteButton() {
        favouriteButton.isHidden = true
    }
}

