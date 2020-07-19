//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest

protocol RetrieveImageDataTask {
    func cancel()
}

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data,Error>
    
    func retrieveImageData(for url: URL, completion: @escaping (Result)-> Void) -> RetrieveImageDataTask
}

protocol FeedImageDataLoadTask {
    func cancel()
}

final class LocalFeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    enum Error: Swift.Error {
        case loadingImageData
        case notFound
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    @discardableResult
    func loadImageData(for url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoadTask {
        let task = LocalFeedImageDataLoadTask(completion: completion)
        
        task.wrappedTask =  store.retrieveImageData(for: url) { [weak self] retrieveResult in
            if self == nil { return }
            
            let loadResult: Result = retrieveResult
                .mapError{ _ in Error.loadingImageData}
                .flatMap{ data in
                    return !data.isEmpty ? .success(data) :.failure(.notFound)
            }
            
            task.complete(with: loadResult)
        }
        
        return task
    }
}

private class LocalFeedImageDataLoadTask: FeedImageDataLoadTask {
    private var completion: ((LocalFeedImageDataLoader.Result) -> Void)?
    var wrappedTask: RetrieveImageDataTask?
    
    init(completion: @escaping (LocalFeedImageDataLoader.Result) -> Void) {
        self.completion = completion
    }
    
    func cancel() {
        wrappedTask?.cancel()
        completion = nil
    }
    
    func complete(with result: LocalFeedImageDataLoader.Result) {
        completion?(result)
    }
}

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_feedImageDataStore_doesNotRequestDataAtInit() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_loadImageData_requestsRetrievalToStore() {
        let (sut, store) = makeSUT()
        let aURL = anyURL()
        
        sut.loadImageData(for: aURL) { _ in}
        
        XCTAssertEqual(store.messages, [.retrieveImageData(aURL)])
    }
    
    func test_loadImageDataTwice_requestsRetrievalToStoreTwice() {
        let (sut, store) = makeSUT()
        let aURL = anyURL()
        let otherUrl = URL(string: "http://other-url.com")!
        
        sut.loadImageData(for: aURL) { _ in }
        sut.loadImageData(for: otherUrl) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieveImageData(aURL), .retrieveImageData(otherUrl)])
    }
    
    func test_loadImageData_completesWithLoadingImageDataErrorOnStoreFailure() {
        let (sut, store) = makeSUT()
        
        loadImageData(sut, andExpect: .failure(.loadingImageData), when: {
            store.completeWithError()
        })
    }
    
    func test_loadImageData_completesWithNotFoundErrorOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        loadImageData(sut, andExpect: .failure(.notFound), when: {
            store.completeWithEmptyCache()
        })
    }
    
    func test_loadImageData_completesWithNotFoundErrorOnNotEmptyCacheButEmptyData() {
        let (sut, store) = makeSUT()
        let emptyData = Data()
        
        loadImageData(sut, andExpect: .failure(.notFound), when: {
            store.completeWith(data: emptyData)
        })
    }
    
    func test_loadImageData_completesWithDataOnNotEmptyCache() {
        let (sut, store) = makeSUT()
        let nonEmptyData = anyData()
        
        loadImageData(sut, andExpect: .success(nonEmptyData), when: {
            store.completeWith(data: anyData())
        })
    }
    
    func test_loadImageData_doesNotCompleteAfterLoaderIsDeallocated() {
        let store = DataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
                
        sut?.loadImageData(for: anyURL()) { _ in
            XCTFail("Expected load to not complete after the sut has been deallocated")
        }
        
        sut = nil
        store.completeWithEmptyCache()
    }
    
    func test_loadImageDataCancel_requestStoreToCancelRetrieval() {
        let (sut, loader) = makeSUT()
        let aURL = anyURL()
        
        let task = sut.loadImageData(for: aURL) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.messages, [ .retrieveImageData(aURL), .cancelRetrieval(aURL) ], "Expected store to receive a cancel request after task cancellation")
    }
    
    func test_loadImageData_doesNotCompleteAfterTaskCancellation() {
        let (sut, loader) = makeSUT()
                
        let task = sut.loadImageData(for: anyURL()) { _ in
            XCTFail("Expected load to not complete after task cancellation")
        }
        
        task.cancel()
        loader.completeWithError()
    }
    
    
}

// MARK:- Helpers

private extension LoadFeedImageDataFromCacheUseCaseTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: DataStoreSpy) {
        let store = DataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func loadImageData(_ sut: LocalFeedImageDataLoader, andExpect expected: LocalFeedImageDataLoader.Result, when action: ()-> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load image data to complete")
        
        sut.loadImageData(for: anyURL()) { result in
            switch (expected, result) {
            case let (.failure(expectedError), .failure(resultError)):
                XCTAssertEqual(expectedError, resultError, "Expected failure result with error \(expectedError) but got \(resultError)", file: file, line: line)
            case let (.success(expectedData), .success(resultData)):
                XCTAssertEqual(expectedData, resultData, "Expected success result with data \(expectedData) but got \(resultData)", file: file, line: line)
            default:
                XCTFail("Expected \(expected) but got \(result)", file: file, line: line)
            }
                        
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}

// MARK: - DataStoreSpy

private class DataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieveImageData(URL)
        case cancelRetrieval(URL)
    }
    
    private struct RetrieveTask: RetrieveImageDataTask {
        private let callback: () -> Void
        
        init(_ callback: @escaping () -> Void) {
            self.callback = callback
        }
        
        func cancel() {
            callback()
        }
    }
    
    private(set) var messages = [Message]()
    private(set) var retrieveCompletions = [(FeedImageDataStore.Result) -> Void]()
    
    func retrieveImageData(for url: URL, completion: @escaping (FeedImageDataStore.Result)-> Void) -> RetrieveImageDataTask {
        messages.append(.retrieveImageData(url))
        retrieveCompletions.append(completion)
        
        return RetrieveTask ({ [weak self] in
            self?.messages.append(.cancelRetrieval(url))
        })
    }
    
    func completeWithError(at index: Int = 0) {
        let storeError = NSError(domain: "DataStoreSpy", code: 0)
        retrieveCompletions[index](.failure(storeError))
    }
    
    func completeWithEmptyCache(at index: Int = 0) {
        let emptyData = Data()
        retrieveCompletions[index](.success(emptyData))
    }
    
    func completeWith(data: Data, at index: Int = 0) {
        retrieveCompletions[index](.success(data))
    }
}
