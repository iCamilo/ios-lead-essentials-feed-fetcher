//  Created by Ivan Fuertes on 19/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
               
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_cacheRetrievalFailed_validateCache_deletesCache() {
        let (store, sut) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed, .deleteCacheFeed])
    }
    
    func test_cacheIsEmpty_validateCache_doesNotDeleteCache() {
        let currentDate = Date()
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_nonExpiredCache_validateCache_doesNotDeleteCache() {
        let currentDate = Date()
        let nonExpiredCacheTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: +1)
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: nonExpiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_expiredCache_validateCache_deletesCache() {
        let currentDate = Date()
        let expiredCacheTimestamp = currentDate.minusFeedCacheMaxAge()
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: expiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed, .deleteCacheFeed])
    }
    
    func test_pastExpiredCache_validateCache_deletesCache() {
        let currentDate = Date()
        let pastExpiredCacheTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: pastExpiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed, .deleteCacheFeed])
    }
    
    func test_feedLoaderIsDeallocated_validateCache_doesNotDeleteCache() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }

    // MARK:- Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (store, sut)
    }
        
}
