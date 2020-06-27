//  Created by Ivan Fuertes on 17/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
               
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (store, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_retrievalFails_load_failsWithError() {
        let (store, sut) = makeSUT()
        let retrievalError = anyNSError()
        let expectedResult: FeedLoader.Result = .failure(retrievalError)
        
        expect(sut, toCompleteWith: expectedResult, when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_emptyCache_load_deliversNoFeedImages() {
        let (store, sut) = makeSUT()
        let expectedResult: FeedLoader.Result = .success([])
        
        expect(sut, toCompleteWith: expectedResult, when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_nonExpiredCache_load_deliversCachedImages() {
        let currentDate = Date()
        let nonExpiredCacheTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT(currentDate: { currentDate })

        let expectedImages = uniqueImageFeed()
        let expectedResult: FeedLoader.Result = .success(expectedImages.model)

        expect(sut, toCompleteWith: expectedResult, when: {
            store.completeRetrieval(with: expectedImages.local, timestamp: nonExpiredCacheTimestamp)
        })
    }
    
    func test_expiredCache_load_deliversNoImages() {
        let currentDate = Date()
        let expiredCacheTimestamp = currentDate.minusFeedCacheMaxAge()
        let (store, sut) = makeSUT(currentDate: { currentDate })

        let expectedImages = uniqueImageFeed()
        let expectedResult: FeedLoader.Result = .success([FeedImage]())

        expect(sut, toCompleteWith: expectedResult, when: {
            store.completeRetrieval(with: expectedImages.local, timestamp: expiredCacheTimestamp)
        })
    }
    
    func test_pastExpiredCache_load_deliversNoImages() {
        let currentDate = Date()
        let pastExpiredCacheTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT(currentDate: { currentDate })

        let expectedImages = uniqueImageFeed()
        let expectedResult: FeedLoader.Result = .success([])

        expect(sut, toCompleteWith: expectedResult, when: {
            store.completeRetrieval(with: expectedImages.local, timestamp: pastExpiredCacheTimestamp)
        })
    }
    
    func test_cacheRetrievalFailed_load_hasNoSideEffect() {
        let (store, sut) = makeSUT()
        
        sut.load() { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_expiredCache_load_hasNoSideEffect() {
        let currentDate = Date()
        let expiredCacheTimestamp = currentDate.minusFeedCacheMaxAge()
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: expiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_pastExpiredCache_load_hasNoSideEffect() {
        let currentDate = Date()
        let pastExpiredCacheTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: pastExpiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_nonExpiredCache_load_hasNoSideEffect() {
        let currentDate = Date()
        let nonExpiredCacheTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: +1)
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: nonExpiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_cacheIsEmpty_load_hasNoSideEffect() {
        let currentDate = Date()
        let (store, sut) = makeSUT(currentDate: { currentDate })
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCacheFeed])
    }
    
    func test_loaderIsDeallocated_storeCompletes_noResultsAreReceived() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [FeedLoader.Result]()
        sut?.load { result in
            receivedResults.append(result)
        }
        sut = nil
                
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    // MARK:- Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
                
        return (store, sut)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: FeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load to complete")
        
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImageFeed), .success(expectedImageFeed)):
                XCTAssertEqual(receivedImageFeed, expectedImageFeed, file: file, line: line)
            case let (.failure(receievedError), .failure(expectedError)):
                XCTAssertEqual(receievedError as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) BUT got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
