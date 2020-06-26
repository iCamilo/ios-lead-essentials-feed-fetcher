//  Created by Ivan Fuertes on 26/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class FeedFetcherFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        cleanStore()
    }
    
    override func tearDown() {
        super.tearDown()
        cleanStore()
    }

    func test_emptyCache_load_completesWithEmptyResult() {
        let sut = makeSUT()
        let expec = expectation(description: "Waiting for load to complete")
        
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [], "Expected empty feed")
            default:
                XCTFail("Expecting empty feed BUT GOT \(result) instead")
            }
            
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 1.0)
    }
    
    func test_noEmptyCache_load_completesWithCachedFeed() {
        let saveSUT = makeSUT()
        let loadSUT = makeSUT()
        let imageFeed = uniqueImageFeed().model
               
        let saveExp = expectation(description: "Waiting for save to complete")
        saveSUT.save(feed: imageFeed) { saveError in
            XCTAssertNil(saveError, "Expecting save to succeed")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "Waiting load to complete")
        loadSUT.load { result in
            switch result {
            case let .success(resultImageFeed):
                XCTAssertEqual(imageFeed, resultImageFeed, "Expected to retrieve cached feed BUT GOT \(result) instead")
            default:
                XCTFail("Expected to retrieve cached feed BUT GOT \(result) instead")
            }
            
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)        
    }
        
    // MARK:- Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(bundle: coreDataFeedStoreBundle, storeURL: testSpecificStoreURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private var userDomainCacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private var testSpecificStoreURL: URL {
        userDomainCacheURL.appendingPathComponent("\(type(of: self)).store")
    }
    
    private var coreDataFeedStoreBundle: Bundle {
        Bundle(for: CoreDataFeedStore.self)
    }
    
    private func cleanStore() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
