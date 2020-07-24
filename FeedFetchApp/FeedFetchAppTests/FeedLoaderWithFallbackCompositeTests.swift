//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher
import FeedFetchApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

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
    
    func expect(_ sut: FeedLoaderWithFallbackComposite, toCompleteFeedLoadWith expected: FeedLoader.Result,file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for feed load to complete")
        
        sut.load { result in
            switch (result, expected) {
            case let (.failure(error as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(expectedError, error, "Expected feed load to fail with error \(expectedError) but got \(error)")
            case let (.success(resultFeed), .success(expectedFeed)):
                XCTAssertEqual(expectedFeed, resultFeed, "Expected feed load to complete with feed \(expectedFeed) but got \(resultFeed)")
            default:
                XCTFail("Expecte load feed to complete with \(expected) but got \(result)")
            }
                        
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
                     
    func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), url: anyURL, description: "anyDescription", location:"anyLocation")]
    }        
    
}
