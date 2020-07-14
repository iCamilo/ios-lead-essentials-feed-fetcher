//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        let errorMessage = Self.localize("LOADING_FEED_ERROR_MESSAGE",
        comment: "Error message when feed load fails")
        
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(FeedErrorViewModel(message: errorMessage))
    }
    
}

extension FeedPresenter {
    public static var title: String {
        let bundle = Bundle(for: FeedPresenter.self)
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: bundle,
                                 comment: "Title for the FeedView")
    }
    
    private static func localize(_ key: String, comment: String) -> String {
        return NSLocalizedString(key,
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: comment)
    }
}
