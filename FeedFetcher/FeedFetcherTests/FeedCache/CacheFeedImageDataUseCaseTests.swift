//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestStoreToInsertData() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [], "Loader should not request to save any data at creation")
    }
    
    func test_saveImageData_doesRequestStoreToInsertData() {
        let (sut, store) = makeSUT()
        let aData = anyData()
        
        sut.saveImageData(aData) {_ in}
        
        XCTAssertEqual(store.messages, [.insertImageData(aData)], "Expected loader to request store to insert data at saveImageData")
    }
    
    func test_saveImageDataTwice_doesRequestStoreToInsertDataTwice() {
        let (sut, store) = makeSUT()
        let aData = anyData()
        let otherData = "Other Data".data(using: .utf8)!
        
        sut.saveImageData(aData) {_ in}
        sut.saveImageData(otherData) {_ in}
        
        XCTAssertEqual(store.messages, [.insertImageData(aData), .insertImageData(otherData)], "Expected loader to request store to insert data as many times as required")
    }
    
    func test_saveImageData_completesWithSavingImageDataErrorOnInsertionError() {
        let (sut, store) = makeSUT()
                
        saveImageData(sut, andExpect: .failure(.savingImageData), when: {
            store.completeInsertionWithError()
        })
    }
    
    func test_saveImageData_completesWithNoErrorOnInsertionSuccess() {
        let (sut, store) = makeSUT()
                
        saveImageData(sut, andExpect: .success(()), when: {
            store.completeInsertionWith(data: anyData())
        })
    }
    
}

// MARK:- Helpers

private extension CacheFeedImageDataUseCaseTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func saveImageData(_ sut: LocalFeedImageDataLoader, andExpect expected: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting save image data to complete")
        
        sut.saveImageData(anyData()) { result in
            switch (expected, result) {
            case (.success, .success):
                break
            case let (.failure(expectedError), .failure(receivedError)):
                XCTAssertEqual(expectedError, receivedError, "Expected to fail with \(expectedError) but got \(receivedError)", file: file, line: line)
            default:
                XCTFail("Expected to complete with \(expected) but got \(result)", file: file, line: line)
            }
                        
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
