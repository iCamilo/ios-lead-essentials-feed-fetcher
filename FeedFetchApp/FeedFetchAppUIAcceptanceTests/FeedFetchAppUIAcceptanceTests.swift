//  Created by Ivan Fuertes on 27/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest

class FeedFetchAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-cell")
        XCTAssertEqual(feedCells.count, 22, "Should retrieve and display remote feed if it has connectivity")
        
        let firstImage = app.cells.images.matching(identifier: "feed-image").firstMatch
        XCTAssertTrue(firstImage.exists, "Should display images if it has connectivity")
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-cell")
        XCTAssertEqual(cachedFeedCells.count, 22, "Should retrieve and display remote feed if it has connectivity")
        
        let firstCachedImage = offlineApp.cells.images.matching(identifier: "feed-image").firstMatch
        XCTAssertTrue(firstCachedImage.exists, "Should display images if it has connectivity")
    }
    
}
