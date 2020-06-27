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
                
        assertLoad(sut, completeWith: [])
    }
    
    func test_noEmptyCache_load_completesWithCachedFeed() {
        let saveSUT = makeSUT()
        let loadSUT = makeSUT()
        let feed = uniqueImageFeed().model
               
        let saveExp = expectation(description: "Waiting for save to complete")
        saveSUT.save(feed: feed) { saveError in
            XCTAssertNil(saveError, "Expecting save to succeed")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        assertLoad(loadSUT, completeWith: feed)
    }
        
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(bundle: coreDataFeedStoreBundle, storeURL: testSpecificStoreURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func assertLoad(_ sut: LocalFeedLoader, completeWith expected: [FeedImage]) {
        let expec = expectation(description: "Waiting for load to complete")
        
        sut.load { result in
            switch result {
            case let .success(resultFeed):
                XCTAssertEqual(expected, resultFeed, "Expected \(expected) BUT GOT \(resultFeed)")
            default:
                XCTFail("Expected success with feed \(expected) BUT GOT \(result)")
            }
            
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 1.0)
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
