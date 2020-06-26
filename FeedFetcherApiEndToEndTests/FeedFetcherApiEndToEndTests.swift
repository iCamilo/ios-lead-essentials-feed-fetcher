//  Created by Ivan Fuertes on 3/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class FeedFetcherApiEndToEndTests: XCTestCase {
    
    func test_remoteFeedLoaderUsingTestingServer_load_returnsEightFeeds() {
        let receivedResult = loadFromTestingServer()
        
        switch receivedResult {
        case let .success(imageFeed):
            XCTAssertEqual(imageFeed.count, 8, "Expect 8 feed images from the testing server")
            imageFeed.enumerated().forEach { (index, image) in
                XCTAssertEqual(image, self.expectedImage(at: index), "Failed feed image at index \(index)")
            }
        case let .failure(error):
            XCTFail("Expected success with 8 feed images but got failure with error: \(error)")
        default:
            XCTFail("Expected success with 8 feed images but got no response")
        }
    }
    
    // MARK: - Helpers
    
    func loadFromTestingServer(file: StaticString = #file, line: UInt = #line) -> RemoteFeedLoader.Result? {
        let testingServerURL = URL(string:"https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHttpClient(session: session)
        let loader = RemoteFeedLoader(from: testingServerURL, httpClient: client)
        
        trackForMemoryLeak(instance: client, file: file, line: line)
        trackForMemoryLeak(instance: loader, file: file, line: line)
        
        let expectation = self.expectation(description: "Waiting for load to complete")
        
        var receivedResult: RemoteFeedLoader.Result?
        loader.load { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedImage(at index: Int) -> FeedImage {
        return FeedImage(id: id(at: index),
                        url: url(at: index),
                        description: description(at: index),
                        location: location(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        let uuids = ["73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                     "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                     "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                     "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                     "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                     "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                     "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                     "F79BD7F8-063F-46E2-8147-A67635C3BB01"]
        
        return UUID(uuidString: uuids[index])!
    }
    
    private func url(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
    
    private func location(at index: Int) -> String? {
        let locations = ["Location 1",
                         "Location 2",
                         nil,
                         nil,
                         "Location 5",
                         "Location 6",
                         "Location 7",
                         "Location 8"]
        
        return locations[index]
    }
    
    private func description(at index: Int) -> String? {
        let descriptions = ["Description 1",
                            nil,
                            "Description 3",
                            nil,
                            "Description 5",
                            "Description 6",
                            "Description 7",
                            "Description 8"]
        
        return descriptions[index]
    }

}
