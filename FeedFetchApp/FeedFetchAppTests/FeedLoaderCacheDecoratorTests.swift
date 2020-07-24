//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

final class FeedLoaderCacheDecorator: FeedLoader {
        
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
        
}

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
        
}

// MARK:- Helpers

private extension FeedLoaderCacheDecoratorTests {
    
    func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
}
