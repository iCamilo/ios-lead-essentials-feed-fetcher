//  Created by Ivan Fuertes on 2/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

final class FeedImageCellController: FeedImageView {
    private lazy var cell = FeedImageCell()
    private let presenter: FeedImagePresenter<UIImage, FeedImageCellController>
        
    init(presenter: FeedImagePresenter<UIImage, FeedImageCellController>) {
        self.presenter = presenter
    }
    
    func view() -> UITableViewCell {
        presenter.loadImageData()
        
        return cell
    }
    
    func preload() {
        presenter.loadImageData()
    }
    
    func cancelLoad() {
        presenter.cancelLoadImageData()
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !viewModel.displayLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = viewModel.image
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = presenter.loadImageData
    }
}
