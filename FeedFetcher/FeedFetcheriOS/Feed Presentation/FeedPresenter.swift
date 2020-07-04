//  Created by Ivan Fuertes on 3/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView: class {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
        
    func didStartLoading() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didSuccessfullyLoad(_ feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFailToLoad() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
