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

final class FeedLoaderCacheDecoratorTests: XCTestCase {
    
    func test_load_deliversFeedOnLoaderSucess() {
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
                        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loaderError = anyError
        let loader = FeedLoaderStub(result: .failure(loaderError))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
                        
        expect(sut, toCompleteWith: .failure(loaderError))
    }
    
    
}

// MARK:- Helpers

private extension FeedLoaderCacheDecoratorTests {
        
    func expect(_ sut: FeedLoaderCacheDecorator, toCompleteWith expected: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load to complete")
        
        sut.load { result in
            switch (result, expected) {
            case let (.success(resultFeed), .success(expectedFeed)):
                XCTAssertEqual(resultFeed, expectedFeed, "Expected load to complete with feed \(expectedFeed) but got \(resultFeed)", file: file, line: line)
            case let (.failure(resultError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(resultError, expectedError, "Expected load to fail with error \(expectedError) but got \(resultError)", file: file, line: line)
            default:
                XCTFail("Expected load to complete with result \(expected) but got \(result)")
            }
                                    
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
