//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
    
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    func test_loadImageData_deliversImageDataOnLoaderSucess() {
        let (sut, loader) = makeSUT()
                
        expect(sut, toCompleteLoadImageDataWith: .success(anyData), from: anyURL, when: {
            loader.complete(with: anyData)
        })
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
                
        expect(sut, toCompleteLoadImageDataWith: .failure(anyError), from: anyURL, when: {
            loader.complete(with: anyError)
        })
    }
    
}

private extension FeedImageDataLoaderCacheDecoratorTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    func expect(_ sut: FeedImageDataLoader, toCompleteLoadImageDataWith expected: FeedImageDataLoader.Result, from url: URL, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
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
    
    var anyData: Data { return "anydata".data(using: .utf8)! }
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
    
    func complete(with data: Data, at index: Int = 0) {
        completions[index](.success(data))
    }
    
    private struct Task: FeedImageDataTask {
        let callback: () -> Void
                        
        func cancel() { callback() }
    }
}
