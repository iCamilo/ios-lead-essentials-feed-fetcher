//  Created by Ivan Fuertes on 2/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import UIKit
import FeedFetcher

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedViewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo feedController: FeedViewController, loader imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return {[weak feedController] feed in
            feedController?.tableModel = feed.map { feedImage in
                FeedImageCellController(viewModel: FeedImageViewModel(model: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init))
            }
        }
    }
}
