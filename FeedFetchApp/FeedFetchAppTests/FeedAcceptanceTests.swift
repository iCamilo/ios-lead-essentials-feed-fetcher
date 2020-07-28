//  Created by Ivan Fuertes on 28/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcheriOS
import FeedFetcher
@testable import FeedFetchApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
        let feedController = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feedController.numberOfRenderedFeedImagesView(), 2)
        XCTAssertEqual(feedController.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feedController.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeedController = launch(httpClient: .online(response), store: sharedStore)
        onlineFeedController.simulateFeedImageViewVisible(at: 0)
        onlineFeedController.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeedController = launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeedController.numberOfRenderedFeedImagesView(), 2)
        XCTAssertEqual(offlineFeedController.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeedController.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let offlineFeedController = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(offlineFeedController.numberOfRenderedFeedImagesView(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
        
        XCTAssertNil(store.feedCache, "Expected to delete feed cache")
    }
    
    // MARK:- Helpers
    
    private func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    private func response(for url: URL) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, makeData(for: url))
    }
    
    private func renderFeedImageData(at index: Int) {
        
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()

        default:
            return makeFeedData()
        }
    }

    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
    
}

// MARK:- HTTPClientStub

class HTTPClientStub: HttpClient {
    private class Task: HttpClientTask {
        func cancel() {}
    }

    private let stub: (URL) -> HttpClient.Result

    init(stub: @escaping (URL) -> HttpClient.Result) {
        self.stub = stub
    }

    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(stub(url))
        return Task()
    }
}

extension HTTPClientStub {
    static var offline: HTTPClientStub {
        HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }

    static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }
    
}

// MARK:- InMemoryFeedStore

class InMemoryFeedStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]

    private init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
}

extension InMemoryFeedStore: FeedStore {
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        feedCache = CachedFeed(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }

    func retrieveCachedFeed(completion: @escaping RetrievalCompletion) {
        completion(.success(feedCache))
    }
}

extension InMemoryFeedStore: FeedImageDataStore {
    func retrieveImageData(for url: URL, completion: @escaping (RetrieveResult) -> Void) {
        completion(.success(feedImageDataCache[url]))
    }
    
    func insertImageData(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        feedImageDataCache[url] = data
        completion(.success(()))
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }

    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
    }

    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
    }
}
