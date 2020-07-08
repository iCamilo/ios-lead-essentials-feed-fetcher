//  Created by Ivan Fuertes on 2/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

public class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
     
    var onRetry: (() -> Void)?
    
    @IBAction func retryButtonTapped() {
        onRetry?()
    }
}
