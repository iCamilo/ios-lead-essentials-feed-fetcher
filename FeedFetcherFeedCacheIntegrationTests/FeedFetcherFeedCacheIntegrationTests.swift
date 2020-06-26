//  Created by Ivan Fuertes on 26/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class FeedFetcherFeedCacheIntegrationTests: XCTestCase {

    func test_emptyCache_load_completesWithEmptyResult() {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
        let store: FeedStore = try! CoreDataFeedStore(bundle: storeBundle, storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        let expec = expectation(description: "Waiting for load to complete")
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [], "Expected empty feed")
            default:
                XCTFail("Expecting empty feed BUT GOT \(result) instead")
            }
            
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 1.0)
    }

}
