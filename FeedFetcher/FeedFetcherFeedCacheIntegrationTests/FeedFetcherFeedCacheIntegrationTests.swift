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
                
        expect(sut, toLoadFeed: [])
    }
    
    func test_noEmptyCache_load_completesWithCachedFeed() {
        let saveSUT = makeFeedLoader()
        let loadSUT = makeFeedLoader()
        let feed = uniqueImageFeed().model
                       
        saveFeed(feed, with: saveSUT)
        
        expect(loadSUT, toLoadFeed: feed)
    }
    
    func test_noEmptyCache_saveRecentFeed_overridesOldFeedWithNewFeed() {
        let saveOldFeedSUT = makeFeedLoader()
        let oldFeed = uniqueImageFeed().model
        let saveRecentFeedSUT = makeFeedLoader()
        let recentFeed = uniqueImageFeed().model        
        let loadSUT = makeFeedLoader()
        
        saveFeed(oldFeed, with: saveOldFeedSUT)
        saveFeed(recentFeed, with: saveRecentFeedSUT)
        
        expect(loadSUT, toLoadFeed: recentFeed)
    }
        
    // MARK:- LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedImageDataUsingTheSameLoaderInstance() {
        let image = uniqueImage()
        let imageData = anyData()
        let imageLoader = makeImageLoader()
        let feedLoader = makeFeedLoader()
                
        saveFeed([image], with: feedLoader)
        saveImageData(imageData, for: image.url, with: imageLoader)
                    
        expect(imageLoader, toLoadImageData: imageData, from: image.url)
    }
    
    func test_loadImageData_deliversSavedImageDataOnASeparateLoaderInstance() {
        let image = uniqueImage()
        let imageData = anyData()
        let imageLoaderToSave = makeImageLoader()
        let imageLoderToLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        
        saveFeed([image], with: feedLoader)
        saveImageData(imageData, for: image.url, with: imageLoaderToSave)
        
        expect(imageLoderToLoad, toLoadImageData: imageData, from: image.url)
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
        let image = uniqueImage()
        let firstImageData = "first".data(using: .utf8)!
        let lastImageData = "last".data(using: .utf8)!
        let imageLoaderToLoad = makeImageLoader()
        
        let feedLoader = makeFeedLoader()
        saveFeed([image], with: feedLoader)
        
        let imageLoaderToSaveFirst = makeImageLoader()
        saveImageData(firstImageData, for: image.url, with: imageLoaderToSaveFirst)
        expect(imageLoaderToLoad, toLoadImageData: firstImageData, from: image.url)
        
        let imageLoaderToSaveLast = makeImageLoader()
        saveImageData(lastImageData, for: image.url, with: imageLoaderToSaveLast)
        expect(imageLoaderToLoad, toLoadImageData: lastImageData, from: image.url)
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
    
    private func expect(_ sut: LocalFeedLoader, toLoadFeed expected: [FeedImage], file: StaticString = #file, line: UInt = #line) {
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
    
    private func saveFeed(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
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
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoadImageData expectedData: Data, from url: URL, file: StaticString = #file, line: UInt = #line) {
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
