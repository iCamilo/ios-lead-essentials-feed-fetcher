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
        let task = LoadImageTask()
        task.wrappedTask = primaryLoader.loadImageData(from: url) {[weak self] primaryResult in
            if case .success = primaryResult {
                return completion(primaryResult)
            }
            
            task.wrappedTask = self?.fallbackLoader.loadImageData(from: url, completion: completion)
        }
        
        return task
    }
    
    private final class LoadImageTask: FeedImageDataTask {
        var wrappedTask: FeedImageDataTask?
        
        func cancel() {
            wrappedTask?.cancel()
        }
    }

    
}

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
        
    func test_loadImageData_completesWithPrimaryImageDataOnPrimaryLoaderSuccess() {
        let primaryData = "primaryData".data(using: .utf8)!
        let fallbackData = "fallbackData".data(using: .utf8)!
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteLoadImageDataWith: .success(primaryData), from: anyURL)
    }
    
    func test_loadImageData_completesWithFallbackImageDataOnPrimaryLoaderFailAndFallbackLoaderSuccess() {
        let fallbackData = "fallbackData".data(using: .utf8)!
        let sut = makeSUT(primaryResult: .failure(anyError), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteLoadImageDataWith: .success(fallbackData), from: anyURL)
    }
    
    func test_loadImageData_completesWithErrorOnBothFallbackPrimaryLoadersFail() {
        let loadImageError = anyError
        let sut = makeSUT(primaryResult: .failure(loadImageError), fallbackResult: .failure(loadImageError))
        
        expect(sut, toCompleteLoadImageDataWith: .failure(loadImageError), from: anyURL)
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
    
    func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoaderWithFallbackComposite {
        let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = FeedImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        trackForMemoryLeak(instance: primaryLoader, file: file, line: line)
        trackForMemoryLeak(instance: fallbackLoader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
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

private final class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private(set) var completions = [(FeedImageDataLoader.Result) -> Void]()
    private(set) var cancelledUrls = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        completions.append(completion)
        return Task(callback: { [weak self] in
            self?.cancelledUrls.append(url)
        })
    }
            
    func complete(with error: NSError, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    private struct Task: FeedImageDataTask {
        let callback: () -> Void
                        
        func cancel() { callback() }
    }
}

