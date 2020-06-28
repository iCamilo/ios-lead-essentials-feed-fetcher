//  Created by Ivan Fuertes on 27/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private weak var locationStackView: UIStackView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var feedImage: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    static let reuseIdentifier = "FeedImageCell"
    
    func configure(with model: FeedImageViewModel) {
        locationStackView.isHidden = model.location == .none
        locationLabel.text = model.location
        descriptionLabel.text = model.description
        feedImage.image = UIImage(named: model.imageName)
    }
    
}
