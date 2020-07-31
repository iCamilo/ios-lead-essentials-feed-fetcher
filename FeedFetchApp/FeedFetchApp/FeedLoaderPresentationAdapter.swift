//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import Combine
import FeedFetcher
import FeedFetcheriOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private var cancellable: Cancellable?
    private let feedLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {                    
                    case .finished:
                        break
                    
                    case let .failure(error):
                        self?.presenter?.didFinishLoadingFeed(with: error)
                    }
                    
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
            })
    }
}
