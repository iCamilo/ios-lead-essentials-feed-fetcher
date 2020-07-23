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

    func test_emptyCache_load_completesWithEmptyFeed() {
        let sut = makeFeedLoader()
                
        assertLoad(sut, completeWith: [])
    }
    
    func test_noEmptyCache_load_completesWithCachedFeed() {
        let saveSUT = makeFeedLoader()
        let loadSUT = makeFeedLoader()
        let feed = uniqueImageFeed().model
                       
        save(saveSUT, feed: feed)
        
        assertLoad(loadSUT, completeWith: feed)
    }
    
    func test_noEmptyCache_saveRecentFeed_overridesOldFeedWithNewFeed() {
        let saveOldFeedSUT = makeFeedLoader()
        let oldFeed = uniqueImageFeed().model
        let saveRecentFeedSUT = makeFeedLoader()
        let recentFeed = uniqueImageFeed().model        
        let loadSUT = makeFeedLoader()
        
        save(saveOldFeedSUT, feed: oldFeed)
        save(saveRecentFeedSUT, feed: recentFeed)
        
        assertLoad(loadSUT, completeWith: recentFeed)
    }
        
    // MARK:- LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedImageDataForSavedFeed() {
        let sut = makeImageLoader()
        
        let image = uniqueImage()
        let localFeedLoader = makeFeedLoader()
        save(localFeedLoader, feed: [image])
            
        let imageData = anyData()
        saveImageData(imageData, for: image.url, with: sut)
                    
        expect(sut, toLoad: imageData, from: image.url)
    }
}
    
// MARK:- Helpers

private extension FeedFetcherFeedCacheIntegrationTests {
        
    private func makeFeedLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL)
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func assertLoad(_ sut: LocalFeedLoader, completeWith expected: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let expec = expectation(description: "Waiting for load to complete")
        
        sut.load { result in
            switch result {
            case let .success(resultFeed):
                XCTAssertEqual(expected, resultFeed, "Expected \(expected) BUT GOT \(resultFeed)", file: file, line: line)
            default:
                XCTFail("Expected success with feed \(expected) BUT GOT \(result)", file: file, line: line)
            }
            
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 1.0)
    }
    
    private func save(_ sut: LocalFeedLoader, feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Waiting for save to complete")
        
        sut.save(feed: feed) { saveResult in
            switch saveResult {
            case let .failure(error):
                XCTFail("Expecting save to succeed BUT failed with \(error)", file: file, line: line)
            default: break
            }
            
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func saveImageData(_ data: Data, for url: URL, with sut: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for save image data to complete")
        
        sut.saveImageData(data, for: url) { result in
            switch result {
            case let .failure(saveResult):
                XCTFail("Save image data failed with error \(saveResult)", file: file, line: line)
            case .success:
                break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, from url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load image data to complete")
        
        let _ = sut.loadImageData(from: url) { loadResult in
            switch loadResult {
            case let .failure(loadError):
                XCTFail("Expected load image to retrieve saved data but failed with error \(loadError)", file: file, line: line)
            case let .success(resultData):
                XCTAssertEqual(expectedData, resultData, "Expected to load image data \(expectedData) but got \(resultData)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
                    
    private var userDomainCacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private var testSpecificStoreURL: URL {
        userDomainCacheURL.appendingPathComponent("\(type(of: self)).store")
    }
        
    private func cleanStore() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
