//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher
import FeedFetchApp

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
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let imageData = anyData
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: anyURL) { _ in }
        loader.complete(with: imageData)
        
        XCTAssertEqual(cache.messages, [.save(imageData)], "Expected to cache loaded image data on success")
    }
    
    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
        let cache = CacheSpy()
        let loadError = anyError
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: anyURL) { _ in }
        loader.complete(with: loadError)
        
        XCTAssertEqual(cache.messages, [], "Expected to not cache loaded image data on failure")
    }
    
}

// MARK:- Helpers

private extension FeedImageDataLoaderCacheDecoratorTests {
    
    func makeSUT(cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        
        trackForMemoryLeak(instance: loader, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    class CacheSpy: FeedImageDataCache {
        
        enum Message:Equatable {
            case save(Data)
        }
        
        private(set) var messages = [Message]()
                
        func saveImageData(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data))
        }
    }
    
}
