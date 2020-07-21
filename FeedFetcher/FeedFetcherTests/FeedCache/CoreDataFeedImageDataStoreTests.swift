//  Created by Ivan Fuertes on 21/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_completesWithNotFoundDataOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Waiting for retrieve image data to complete")
        sut.retrieveImageData(for: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, nil)
            default:
                XCTFail("Expected to complete with not found data on empty cache, but got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveImageData_completesWithNotFoundForNonStoredURL() {
        let sut = makeSUT()
        let storeImage = localImage(url: anyURL())
        let storeImageURL = storeImage.url
        let noStoreImageURL = URL(string: "http://no-storedImageURL.png")!
                
        let insertExp = expectation(description: "Waiting insert image data to complete")
        sut.insert([storeImage], timestamp: Date()) { insertFeedResult in
            switch insertFeedResult {
            case let .failure(insertFeedImageError):
                XCTFail("Failed to insert feed image with error \(insertFeedImageError)")
                insertExp.fulfill()
                
            case .success:
                sut.insertImageData(anyData(), for: storeImageURL) { insertDataResult in
                    if case let .failure(error) = insertDataResult {
                        XCTFail("Failed to insert image data with error \(error)")
                    }
                    
                    insertExp.fulfill()
                }
                
            }
        }
        wait(for: [insertExp], timeout: 1.0)
                                        
        let exp = expectation(description: "Waiting for retrieve image data to complete")
        sut.retrieveImageData(for: noStoreImageURL) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, nil, "Expected not found data for url that is not stored")
            default:
                XCTFail("Expected to complete with not found data for url that is not stored, but got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
    
    func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), url: url, description: "any", location: "any")
    }
    
}

