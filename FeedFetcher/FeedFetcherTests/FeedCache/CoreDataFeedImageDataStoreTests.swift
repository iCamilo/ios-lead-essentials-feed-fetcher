//  Created by Ivan Fuertes on 21/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_completesWithNotFoundDataOnEmptyCache() {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let testSpecificURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(bundle: bundle, storeURL: testSpecificURL)
        
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

