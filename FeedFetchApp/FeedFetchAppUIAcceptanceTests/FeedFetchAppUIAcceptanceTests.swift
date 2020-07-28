//  Created by Ivan Fuertes on 27/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest

class FeedFetchAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
        let onlineApp = launchOnlineApp()
        
        let feedCells = feedCellsQuery(for: onlineApp)
        XCTAssertEqual(feedCells.count, 22, "Should retrieve and display remote feed if it has connectivity")
        
        let firstImage = feedImagesQuery(for: onlineApp).firstMatch
        XCTAssertTrue(firstImage.exists, "Should display images if it has connectivity")
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        launchOnlineApp()
        
        let offlineApp = launchOfflineApp()
        
        let cachedFeedCells = feedCellsQuery(for: offlineApp)
        XCTAssertEqual(cachedFeedCells.count, 22, "Should retrieve and display remote feed if it has connectivity")
        
        let firstCachedImage = feedImagesQuery(for: offlineApp).firstMatch
        XCTAssertTrue(firstCachedImage.exists, "Should display images if it has connectivity")
    }
    
}

// MARK:- Helpers

private extension FeedFetchAppUIAcceptanceTests {
            
    @discardableResult
    func launchOnlineApp() -> XCUIApplication {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        return onlineApp
    }
    
    @discardableResult
    func launchOfflineApp() -> XCUIApplication {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
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
