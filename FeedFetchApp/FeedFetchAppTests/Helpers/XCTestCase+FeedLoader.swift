//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

extension XCTestCase {
    
    func expect(_ sut: FeedLoader, toCompleteFeedLoadWith expected: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load to complete")
        
        sut.load { result in
            switch (result, expected) {
            case let (.success(resultFeed), .success(expectedFeed)):
                XCTAssertEqual(resultFeed, expectedFeed, "Expected load to complete with feed \(expectedFeed) but got \(resultFeed)", file: file, line: line)
            case let (.failure(resultError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(resultError, expectedError, "Expected load to fail with error \(expectedError) but got \(resultError)", file: file, line: line)
            default:
                XCTFail("Expected load to complete with result \(expected) but got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
