//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
            
    init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        let _ = fallbackLoader.loadImageData(from: url) {[weak self] fallbackResult in
            if case .success = fallbackResult {
                return completion(fallbackResult)
            }
            
            let _ = self?.primaryLoader.loadImageData(from: url, completion: completion)
        }
        
        return LoadImageTask()
    }
    
    private final class LoadImageTask: FeedImageDataTask {
        func cancel() {}
    }

    
}

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
        
    func test_loadImageData_completesWithFallbackImageDataOnFallbackLoaderSuccees() {
        let fallbackData = "fallbackData".data(using: .utf8)!
        let sut = makeSUT(primaryResult: .failure(anyError), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteLoadImageDataWith: .success(fallbackData), from: anyURL)
    }
    
    func test_loadImageData_completesWithPrimaryImageDataOnFallbackLoaderFailsAndPrimaryLoaderSuccess() {
        let primaryData = "primaryData".data(using: .utf8)!
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .failure(anyError))
        
        expect(sut, toCompleteLoadImageDataWith: .success(primaryData), from: anyURL)
    }
    
    func test_loadImageData_completesWithErrorOnBothFallbackPrimaryLoadersFail() {
        let loadImageError = anyError
        let sut = makeSUT(primaryResult: .failure(loadImageError), fallbackResult: .failure(loadImageError))
        
        expect(sut, toCompleteLoadImageDataWith: .failure(loadImageError), from: anyURL)
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
    
    func expect(_ sut: FeedImageDataLoaderWithFallbackComposite, toCompleteLoadImageDataWith expected: FeedImageDataLoader.Result, from url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load image data to complete")
        
        let _ = sut.loadImageData(from: url) { result in
            switch (expected, result) {
            case let (.failure(expectedError as NSError), .failure(resultError as NSError)):
                XCTAssertEqual(expectedError, resultError, "Expected load image data to fail with \(expectedError) but got \(resultError)", file: file, line: line)
            case let (.success(expectedData), .success(resultData)):
                XCTAssertEqual(expectedData, resultData, "Expected load image data to complete with \(expectedData) but got \(resultData)", file: file, line: line)
            default:
                XCTFail("Expected load image data to complete with \(expected) but got \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
