//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryLoader: FeedImageDataLoader
            
    init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        let _ = primaryLoader.loadImageData(from: url) { primaryResult in
            completion(primaryResult)
        }
        
        return LoadImageTask()
    }
    
    private final class LoadImageTask: FeedImageDataTask {
        func cancel() {}
    }

    
}

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadImageData_completesWithPrimaryImageDataOnPrimaryLoaderSucceed() {
        let primaryData = "primaryData".data(using: .utf8)!
        let fallbackData = "fallbackData".data(using: .utf8)!
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
        
        let exp = expectation(description: "Waiting for load image data to complete")
        let _ = sut.loadImageData(from: anyURL) { result in
            switch result {
            case let .failure(error):
                XCTFail("Expected load image data to complete but got error \(error)")
            case let .success(resultData):
                XCTAssertEqual(primaryData, resultData, "Expected load image data to complete with \(primaryData) but got \(resultData)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}

// MARK:- Helpers

private extension FeedImageLoaderWithFallbackCompositeTests {
    
    func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoaderWithFallbackComposite {
        let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = FeedImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        trackForMemoryLeak(instance: primaryLoader, file: file, line: line)
        trackForMemoryLeak(instance: fallbackLoader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    var anyURL: URL { return URL(string: "http://any-url.com")! }
    
    func trackForMemoryLeak(instance: AnyObject, file: StaticString, line: UInt) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Check For Possible Memory Leak", file: file, line: line)
        }
    }
    
}

// MARK:- FeedImageDataLoaderStub

private final class FeedImageDataLoaderStub: FeedImageDataLoader {
    private let result: FeedImageDataLoader.Result
    
    init(result: FeedImageDataLoader.Result) {
        self.result = result
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        completion(result)
        
        return Task()
    }
    
    private class Task: FeedImageDataTask {
        func cancel() { }
    }
    
    
}
