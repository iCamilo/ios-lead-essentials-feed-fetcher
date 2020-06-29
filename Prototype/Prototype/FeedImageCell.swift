//  Created by Ivan Fuertes on 27/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private weak var locationStackView: UIStackView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var feedImageContainer: UIView!
    @IBOutlet private weak var feedImage: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    static let reuseIdentifier = "FeedImageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImage.alpha = 0
        feedImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImage.alpha = 0
        feedImageContainer.startShimmering()
    }
    
    func configure(with model: FeedImageViewModel) {
        locationStackView.isHidden = model.location == .none
        locationLabel.text = model.location
        descriptionLabel.text = model.description
        fadeIn(UIImage(named: model.imageName))
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImage.image = image
        
        UIView.animate(withDuration: 0.25, delay: 1.25, options: [], animations: {
            self.feedImage.alpha = 1
        }, completion: { completed in
            if completed {
                self.feedImageContainer.stopShimmering()
            }
        })
    }
}

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }

    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height

        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }

    func stopShimmering() {
        layer.mask = nil
    }
}
