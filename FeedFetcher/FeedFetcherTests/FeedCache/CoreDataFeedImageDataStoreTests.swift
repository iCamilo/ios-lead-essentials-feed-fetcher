//  Created by Ivan Fuertes on 21/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_completesWithNotFoundDataOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .success(.none), for: anyURL())
    }
    
    func test_retrieveImageData_completesWithNotFoundForNonStoredURL() {
        let sut = makeSUT()
        let url = anyURL()
        let nonExistentURL = URL(string: "http://no-storedImageURL.png")!
                                
        insert(anyData(), for: url, into: sut)
                                        
        expect(sut, toCompleteRetrievalWith: .success(.none), for: nonExistentURL)
    }
    
    func test_retrieveImageData_completesWithFoundDataForStoredURL() {
        let sut = makeSUT()
        let url = anyURL()
        let data = anyData()
                                
        insert(data, for: url, into: sut)
                                        
        expect(sut, toCompleteRetrievalWith: .success(data), for: url)
    }
    
    func test_retrieveImageData_completesWithLastInsertedValue() {
        let sut = makeSUT()
        let url = anyURL()
        let previousData = "previous data".data(using: .utf8)!
        let latestData = "latest data".data(using: .utf8)!
        
        insert(previousData, for: url, into: sut)
        insert(latestData, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(latestData), for: url)
    }
    
}

// MARK:- Helpers

private extension CoreDataFeedImageDataStoreTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let testSpecificURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(bundle: bundle, storeURL: testSpecificURL)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expected: FeedImageDataStore.RetrieveResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrieve image data to complete")
        
        sut.retrieveImageData(for: url) { result in
            switch (expected, result) {
            
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, "Expected success with image data \(expected) but got \(result) instead", file: file, line: line)
                                        
            default:
                XCTFail("Expected to complete with not found data for url that is not stored, but got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let image = localImage(url: url)
        let exp = expectation(description: "Waiting insert image data to complete")
        
        sut.insert([image], timestamp: Date()) { insertFeedResult in
            switch insertFeedResult {
            
            case let .failure(insertFeedImageError):
                XCTFail("Failed to insert feed image with error \(insertFeedImageError)", file: file, line: line)
                exp.fulfill()
                
            case .success:
                sut.insertImageData(data, for: url) { insertDataResult in
                    switch insertDataResult {
                    case .success:
                        break
                    case let .failure(error):
                        XCTFail("Failed to insert image data with error \(error)", file: file, line: line)
                    }
                    
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), url: url, description: "any", location: "any")
    }
    
}

