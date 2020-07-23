//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primaryFeedLoader: FeedLoader
    private let fallbackFeedLoader: FeedLoader
    
    init(primaryFeedLoader: FeedLoader, fallbackFeedLoader: FeedLoader) {
        self.primaryFeedLoader = primaryFeedLoader
        self.fallbackFeedLoader = fallbackFeedLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryFeedLoader.load { remoteResult in
            completion(remoteResult)
        }
    }
    
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_completesWithPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryFeedLoader = FeedLoaderStub(result: .success(primaryFeed))
        let fallbackFeedLoader = FeedLoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primaryFeedLoader: primaryFeedLoader, fallbackFeedLoader: fallbackFeedLoader)
                    
        let exp = expectation(description: "Waiting for feed load to complete")
        sut.load { result in
            switch result {
            case let .failure(error):
                XCTFail("Expected feed load to succeed but got an error \(error)")
            case let .success(resultFeed):
                XCTAssertEqual(primaryFeed, resultFeed, "Expected feed load to complete with primary loader feed \(primaryFeed) but got \(resultFeed)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK:- Helpers
    
    var anyURL: URL { return URL(string: "http://any-url.com")! }
            
    func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), url: anyURL, description: "anyDescription", location:"anyLocation")]
    }
    
}

// MARK:- FeedLoaderStub

private final class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
        
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
    
}
