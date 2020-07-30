//  Created by Ivan Fuertes on 28/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcheriOS
import FeedFetcher
import FeedFetcherAPI
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
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete feed cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep feed cache")
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
    
    private func enterBackground(with store: FeedStore & FeedImageDataStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
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
