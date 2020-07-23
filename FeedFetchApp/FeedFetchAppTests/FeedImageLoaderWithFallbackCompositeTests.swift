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
        let url = URL(string: "http://any-url.com")!
        let primaryData = "primaryData".data(using: .utf8)!
        let fallbackData = "fallbackData".data(using: .utf8)!
        let primaryLoader = FeedImageDataLoaderStub(result: .success(primaryData))
        let fallbackLoader = FeedImageDataLoaderStub(result: .success(fallbackData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        let exp = expectation(description: "Waiting for load image data to complete")
        let _ = sut.loadImageData(from: url) { result in
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
