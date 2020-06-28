//  Created by Ivan Fuertes on 27/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private weak var locationStackView: UIStackView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var feedImage: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    static let reuseIdentifier = "FeedImageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImage.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImage.alpha = 0
    }
    
    func configure(with model: FeedImageViewModel) {
        locationStackView.isHidden = model.location == .none
        locationLabel.text = model.location
        descriptionLabel.text = model.description
        fadeIn(UIImage(named: model.imageName))
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImage.image = image
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            self.feedImage.alpha = 1
        })
    }
}
