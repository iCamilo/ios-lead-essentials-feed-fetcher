//  Created by Ivan Fuertes on 8/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import FeedFetcheriOS

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell {
        let view = simulateFeedImageViewVisible(at: index)!
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: indexPath)
        
        return view
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImagesView() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    var isShowingErrorIndicator: Bool {
        return errorView.message != nil
    }
    
    var errorIndicatorMessage: String? {
        return errorView.message
    }

}
