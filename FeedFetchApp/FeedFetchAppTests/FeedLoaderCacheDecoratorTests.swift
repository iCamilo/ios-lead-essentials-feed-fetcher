//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher
import FeedFetchApp

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSucess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
                        
        expect(sut, toCompleteFeedLoadWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loaderError = anyError        
        let sut = makeSUT(loaderResult: .failure(loaderError))
                        
        expect(sut, toCompleteFeedLoadWith: .failure(loaderError))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheLoadedFeedOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyError), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [], "Expected to not cache loaded feed on failure")
    }
        
}

// MARK:- Helpers

private extension FeedLoaderCacheDecoratorTests {
    
    func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    class CacheSpy: FeedCache {
        
        enum Message:Equatable {
            case save([FeedImage])
        }
        
        private(set) var messages = [Message]()
        
        func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
        
    }
    
}
