//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data,Error>
    
    func retrieveImageData(for url: URL, completion: @escaping (Result)-> Void)
}

final class LocalFeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    enum Error: Swift.Error {
        case loadingImageData
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(for url: URL, completion: @escaping (Result) -> Void) {
        store.retrieveImageData(for: url) { result in
            completion(.failure(.loadingImageData))
        }
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
        let aURL = anyURL()
        
        let exp = expectation(description: "Waiting for load image data to complete")
        sut.loadImageData(for: aURL) { result in
            XCTAssertEqual(result, .failure(.loadingImageData), "Expected to complete with loadingImageData error but got \(result) instead")
            exp.fulfill()
        }
        
        store.completeWith(error: NSError(domain: "Tests", code: 0))
        wait(for: [exp], timeout: 1.0)
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
    
}

// MARK: - DataStoreSpy

private class DataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieveImageData(URL)
    }
    
    private(set) var messages = [Message]()
    private(set) var retrieveCompletions = [(FeedImageDataStore.Result) -> Void]()
    
    func retrieveImageData(for url: URL, completion: @escaping (FeedImageDataStore.Result)-> Void) {
        messages.append(.retrieveImageData(url))
        retrieveCompletions.append(completion)
    }
    
    func completeWith(error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
}
