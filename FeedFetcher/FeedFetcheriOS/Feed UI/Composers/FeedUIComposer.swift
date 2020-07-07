//  Created by Ivan Fuertes on 2/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import UIKit
import FeedFetcher

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(loadFeed: feedPresentationAdapter.loadFeed)
        let feedController = FeedViewController(refreshController: refreshController)
        let feedPresenter = FeedPresenter(feedLoadingView: WeakRefVirtualProxy(refreshController), feedView: FeedViewAdapter(feedController: feedController, imageLoader: imageLoader))

        feedPresentationAdapter.feedPresenter = feedPresenter
                        
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView  {
    private weak var feedController: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(feedController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedController = feedController
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        feedController?.tableModel = viewModel.feed.map { feedImage in
            let presenter = FeedImagePresenter<UIImage, FeedImageCellController>(model: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init)
            let view = FeedImageCellController(presenter: presenter)
            presenter.feedImageView = view
            
            return view
        }
    }
}

private final class FeedLoaderPresentationAdapter {
    var feedPresenter: FeedPresenter?
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedPresenter?.didStartLoading()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedPresenter?.didSuccessfullyLoad(feed)
            } else {
                self?.feedPresenter?.didFailToLoad()
            }
        }
    }
}
