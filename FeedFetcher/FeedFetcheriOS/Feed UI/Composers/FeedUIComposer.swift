//  Created by Ivan Fuertes on 2/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import UIKit
import FeedFetcher

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        feedPresenter.feedLoadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(feedController: feedController, imageLoader: imageLoader)
                
        return feedController
    }
}

private final class FeedViewAdapter: FeedView  {
    private weak var feedController: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(feedController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedController = feedController
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        feedController?.tableModel = feed.map { feedImage in
            FeedImageCellController(viewModel: FeedImageViewModel(model: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}
