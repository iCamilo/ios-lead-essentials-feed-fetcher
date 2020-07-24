//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher
import FeedFetchApp

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
        
    func test_loadImageData_completesWithPrimaryImageDataOnPrimaryLoaderSuccess() {
        let primaryData = "primaryData".data(using: .utf8)!
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, toCompleteLoadImageDataWith: .success(primaryData), from: anyURL, when: {
            primaryLoader.complete(with: primaryData)
        })
    }
    
    func test_loadImageData_completesWithFallbackImageDataOnPrimaryLoaderFailAndFallbackLoaderSuccess() {
        let fallbackData = "fallbackData".data(using: .utf8)!
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteLoadImageDataWith: .success(fallbackData), from: anyURL, when: {
            primaryLoader.complete(with: anyError)
            fallbackLoader.complete(with: fallbackData)
        })
    }
    
    func test_loadImageData_completesWithErrorOnBothFallbackPrimaryLoadersFail() {
        let loadImageError = anyError
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteLoadImageDataWith: .failure(loadImageError), from: anyURL, when: {
            primaryLoader.complete(with: loadImageError)
            fallbackLoader.complete(with: loadImageError)
        })
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let url = anyURL
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledUrls, [url], "Primary loader expected to cancel data load if task is cancelled before it completes")
        XCTAssertEqual(fallbackLoader.cancelledUrls, [], "Secondary loader expected to no cancel anything as the data load has been cancelled before it is even called")
    }
    
    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let url = anyURL
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyError)
        
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledUrls, [], "Primary loader expected to not cancel data load as it has already completed")
        XCTAssertEqual(fallbackLoader.cancelledUrls, [url], "Fallback loader expected to cancel data load as task is cancelled before it completes")
    }
}

// MARK:- Helpers

private extension FeedImageLoaderWithFallbackCompositeTests {
            
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primaryLoader: FeedImageDataLoaderSpy, fallbackLoader: FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        trackForMemoryLeak(instance: primaryLoader, file: file, line: line)
        trackForMemoryLeak(instance: fallbackLoader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
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
    
    func expect(_ sut: FeedImageDataLoaderWithFallbackComposite, toCompleteLoadImageDataWith expected: FeedImageDataLoader.Result, from url: URL, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
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
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
            
}
