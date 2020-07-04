//  Created by Ivan Fuertes on 2/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

final class FeedImageCellController {
    private var viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoadImageData()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.displayLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
                                                
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
