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

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
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
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyURL
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledUrls, [url], "Expected to cancel URL loading from loader")
    }
    
}

// MARK:- Helpers

private extension FeedImageDataLoaderCacheDecoratorTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, loader)
    }
    
}
