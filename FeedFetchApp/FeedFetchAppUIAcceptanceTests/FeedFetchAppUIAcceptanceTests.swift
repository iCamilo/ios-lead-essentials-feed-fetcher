//  Created by Ivan Fuertes on 27/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest

class FeedFetchAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
        let onlineApp = launchOnlineApp(resetLocalCache: true)
        
        let feedCells = feedCellsQuery(for: onlineApp)
        XCTAssertEqual(feedCells.count, 2, "Should retrieve and display remote feed if it has connectivity")
        
        let firstImage = feedImagesQuery(for: onlineApp).firstMatch
        XCTAssertTrue(firstImage.exists, "Should display images if it has connectivity")
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        launchOnlineApp(resetLocalCache: true)
        
        let offlineApp = launchOfflineApp()
        
        let cachedFeedCells = feedCellsQuery(for: offlineApp)
        XCTAssertEqual(cachedFeedCells.count, 2, "Should display cached feed if it has no connectivity and has cached results")
        
        let firstCachedImage = feedImagesQuery(for: offlineApp).firstMatch
        XCTAssertTrue(firstCachedImage.exists, "Should display cached images if it has no connectivity and has cached results")
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let offlineApp = launchOfflineApp(resetLocalCache: true)
        
        let cachedFeedCells = feedCellsQuery(for: offlineApp)
        XCTAssertEqual(cachedFeedCells.count, 0, "Should display empty feed if it has no connectivity and no cache")
    }
    
}

// MARK:- Helpers

private extension FeedFetchAppUIAcceptanceTests {
            
    @discardableResult
    func launchOnlineApp(resetLocalCache: Bool = false) -> XCUIApplication {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-connectivity", "online"]
        if resetLocalCache {
            onlineApp.launchArguments.append("-reset")
        }
        onlineApp.launch()
        
        return onlineApp
    }
    
    @discardableResult
    func launchOfflineApp(resetLocalCache: Bool = false) -> XCUIApplication {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        if resetLocalCache {
            offlineApp.launchArguments.append("-reset")
        }
        offlineApp.launch()
        
        return offlineApp
    }
    
    func feedCellsQuery(for app: XCUIApplication) -> XCUIElementQuery {
        return app.cells.matching(identifier: "feed-cell")
    }
    
    func feedImagesQuery(for app: XCUIApplication) -> XCUIElementQuery {
        return app.cells.images.matching(identifier: "feed-image")
    }
    
}
