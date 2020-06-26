//  Created by Ivan Fuertes on 26/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class FeedFetcherFeedCacheIntegrationTests: XCTestCase {

    func test_emptyCache_load_completesWithEmptyResult() {
        let sut = makeSUT()
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
    
    // MARK:- Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(bundle: coreDataFeedStoreBundle, storeURL: testSpecificStoreURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private var userDomainCacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private var testSpecificStoreURL: URL {
        userDomainCacheURL.appendingPathComponent("\(type(of: self)).store")
    }
    
    private var coreDataFeedStoreBundle: Bundle {
        Bundle(for: CoreDataFeedStore.self)
    }
    
    

}
