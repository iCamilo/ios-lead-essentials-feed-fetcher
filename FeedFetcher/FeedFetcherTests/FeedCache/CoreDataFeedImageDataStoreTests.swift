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
    
}

