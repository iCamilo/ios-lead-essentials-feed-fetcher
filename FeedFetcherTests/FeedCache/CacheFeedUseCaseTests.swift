//  Created by Ivan Fuertes on 15/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
               
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (store, sut) = makeSUT()
        
        sut.save(feed: uniqueImageFeed().model) {_ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_onDeletionError_save_doesNotRequestCacheInsertion() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(feed: uniqueImageFeed().model) {_ in }
        store.completeDeletion(with: deletionError)
                        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
        
    func test_onDeletionSuccess_save_requestsCacheInsertionWithTimestamp() {
        let timestamp = Date()
        let imageFeed = uniqueImageFeed()
        let localFeed = imageFeed.local
        let (store, sut) = makeSUT(currentDate: { timestamp })
                
        sut.save(feed: imageFeed.model) {_ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(localFeed, timestamp)])
    }
    
    func test_onDeletionError_save_failsWithError() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
                                
        assert(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_onInsertError_save_failsWithError() {
        let (store, sut) = makeSUT()
        let insertError = anyNSError()
        
        assert(sut, toCompleteWithError: insertError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertError)
        }
    }
    
    func test_onCacheDeleteAndInsertSucceed_save_succeeds() {
        let (store, sut) = makeSUT()
        
        assert(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_onLoaderDeallocation_deleteCacheFails_shouldNotReceiveDeletionError() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        let deletionError = anyNSError()
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(feed: uniqueImageFeed().model) { error in
            receivedResults.append(error)
        }
        
        sut = nil
        store.completeDeletion(with: deletionError)
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_onLoaderDeallocation_insertCacheFails_shouldNotReceiveInsertionError() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        let insertionError = anyNSError()
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(feed: uniqueImageFeed().model) { error in
            receivedResults.append(error)
        }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: insertionError)
                
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
    
    private func assert(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(feed: uniqueImageFeed().model) { saveResult in
            switch saveResult {
            case let .failure(error):
                receivedError = error
            default: break
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
            
}



