//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher
import FeedFetchApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {

    func test_load_completesWithPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
             
        expect(sut, toCompleteFeedLoadWith: .success(primaryFeed))
    }
    
    func test_load_completesWithFallbackFeedOnPrimaryLoaderFailureAndFallbackLoaderSuccess() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyError), fallbackResult: .success(fallbackFeed))
                  
        expect(sut, toCompleteFeedLoadWith: .success(fallbackFeed))
    }
    
    func test_load_completesWithErrorOnPrimaryAndFallbackLoadersFail() {
        let primaryError = NSError(domain: "Primary Loader Error", code: 0)
        let fallbackError = NSError(domain: "Fallback Loader Error", code: 0)
    
        let sut = makeSUT(primaryResult: .failure(primaryError), fallbackResult: .failure(fallbackError))
             
        expect(sut, toCompleteFeedLoadWith: .failure(fallbackError))
    }
}

// MARK:- Helpers

private extension FeedLoaderWithFallbackCompositeTests{
            
    func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result,  file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryFeedLoader = FeedLoaderStub(result: primaryResult)
        let fallbackFeedLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primaryFeedLoader: primaryFeedLoader, fallbackFeedLoader: fallbackFeedLoader)
        
        trackForMemoryLeak(instance: primaryFeedLoader, file: file, line: line)
        trackForMemoryLeak(instance: fallbackFeedLoader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
}
