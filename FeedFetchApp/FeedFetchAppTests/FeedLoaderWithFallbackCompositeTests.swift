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
        primaryFeedLoader.load { primaryResult in
            if case .success = primaryResult {
                return completion(primaryResult)
            }
            
            self.fallbackFeedLoader.load { fallbackResult in
                completion(fallbackResult)
            }
        }
    }
    
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_completesWithPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
                    
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
    
    func test_load_completesWithFallbackFeedOnPrimaryLoaderFailureAndFallbackLoaderSuccess() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyError), fallbackResult: .success(fallbackFeed))
                    
        let exp = expectation(description: "Waiting for feed load to complete")
        sut.load { result in
            switch result {
            case let .failure(error):
                XCTFail("Expected feed load to succeed but got an error \(error)")
            case let .success(resultFeed):
                XCTAssertEqual(fallbackFeed, resultFeed, "Expected feed load to complete with fallback feed \(fallbackFeed) but got \(resultFeed)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK:- Helpers
    
    func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result,  file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryFeedLoader = FeedLoaderStub(result: primaryResult)
        let fallbackFeedLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primaryFeedLoader: primaryFeedLoader, fallbackFeedLoader: fallbackFeedLoader)
        
        trackForMemoryLeak(instance: primaryFeedLoader, file: file, line: line)
        trackForMemoryLeak(instance: fallbackFeedLoader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    var anyURL: URL { return URL(string: "http://any-url.com")! }
    var anyError: NSError { return NSError(domain: "FeedLoaderCompositeTest", code: 0) }
            
    func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), url: anyURL, description: "anyDescription", location:"anyLocation")]
    }
    
    func trackForMemoryLeak(instance: AnyObject, file: StaticString, line: UInt) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Check For Possible Memory Leak", file: file, line: line)
        }
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
