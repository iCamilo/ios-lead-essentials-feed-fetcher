//  Created by Ivan Fuertes on 27/05/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher

class RemoteFeedLoaderTests: XCTestCase {
        
    func test_initWithClient_load_noRequestsDataFromUrl() {
        let (_, httpClient) = makeSUT()
                        
        XCTAssertTrue(httpClient.requestedURLs.isEmpty)
    }
    
    func test_initWithClient_load_requestsDataFromUrl() {
        let url = anyURL()
        let (loader, httpClient) = makeSUT(url: url)
        
        loader.load() { _ in }
                        
        XCTAssertEqual([url], httpClient.requestedURLs)
    }
    
    func test_initWithClient_loadTwice_requestsDataTwiceFromUrl() {
        let url = anyURL()
        let (loader, httpClient) = makeSUT(url: url)
        
        loader.load() { _ in }
        loader.load() { _ in }
                        
        XCTAssertEqual(httpClient.requestedURLs , [url, url])
    }
    
    func test_clientError_load_returnsConnectivityError() {
        let (loader, client) = makeSUT()
        
        executeAndAssert(forSUT: loader, expected: failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(withError: clientError)
        }
    }
    
    func test_httpResponseIsNot200_load_returnsInvalidDataError() {
        let (loader, client) = makeSUT()
        let statusCodes = [199, 201, 400, 900]
        
        statusCodes.enumerated().forEach { index, code in
            executeAndAssert(forSUT: loader, expected: failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_200HttpStatusCodeAndInvalidJSON_load_returnsInvalidDataError() {
        let (loader, client) = makeSUT()
        
        executeAndAssert(forSUT: loader, expected: failure(.invalidData)) {
            let invalidJSON = Data("invalidJSON".utf8)
            client.complete(withStatusCode: 200, data:invalidJSON)
        }
    }
    
    func test_200HttpStatusCodeAndEmptyListJSON_load_returnsEmptyFeedItemsArray() {
        let (loader, client) = makeSUT()
        
        executeAndAssert(forSUT: loader, expected: .success([FeedImage]())) {
            let emptyListJSON = Data("{ \"items\": [] }".utf8)
            client.complete(withStatusCode: 200, data:emptyListJSON)
        }
    }
    
    func test_200HttpStatusCodeAndItemsListJSON_load_returnsFeedItemsArray() {
        let item = makeFeedItem(id: UUID(), url: anyURL())
        let itemWithDescription = makeFeedItem(id: UUID(), url: anyURL(), description: "a description")
        let itemWithLocation = makeFeedItem(id: UUID(), url: anyURL(), location:"a location")
        
        let feedItems = [item.model, itemWithDescription.model, itemWithLocation.model]
        let feedItemsJSON = ["items" : [item.json, itemWithDescription.json, itemWithLocation.json] ]
        
        let (loader, client) = makeSUT()
        
        executeAndAssert(forSUT: loader, expected: .success(feedItems)) {
            let json = try! JSONSerialization.data(withJSONObject: feedItemsJSON)
            client.complete(withStatusCode: 200, data:json)
        }
    }
    
    func test_sutHasBeenDeallocated_load_noResponseShouldBeReceived() {
        let url = anyURL()
        let client = HttpClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(from: url, httpClient: client)
        
        var receivedResults: RemoteFeedLoader.Result?
        sut?.load {
            receivedResults = $0
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: Data("{ \"items\": [] }".utf8))
        
        XCTAssertNil(receivedResults, "No result should be received if RemoteLoader has been deallocated")
    }
}

private extension RemoteFeedLoaderTests {
    
    func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (loader: RemoteFeedLoader, httpClient: HttpClientSpy) {
        let httpClient = HttpClientSpy()
        let sut = RemoteFeedLoader(from: url, httpClient: httpClient)
        
        trackForMemoryLeak(instance: httpClient, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, httpClient)
    }
        
    func makeFeedItem(id: UUID, url: URL, description: String? = nil, location: String? = nil) -> (model: FeedImage, json: [String : Any]) {
        let feedItem = FeedImage(id: id, url: url, description: description, location:location)
        let json = [
            "id": id.uuidString,
            "image": url.absoluteString,
            "description": description,
            "location": location
            ].compactMapValues { $0 }
        
        return (feedItem, json)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> FeedLoader.Result {
        return .failure(error)
    }
    
    func executeAndAssert(forSUT loader: RemoteFeedLoader, expected: FeedLoader.Result,
                     file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        let expectation = self.expectation(description: "Wait for load completion")
        
        loader.load { receivedResult in
            switch (receivedResult, expected) {
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            default:
                XCTFail("Expected result \(expected) but got \(receivedResult)", file: file, line: line)
            }
            expectation.fulfill()
        }
                
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
}

private class HttpClientSpy: HttpClient {
    typealias Completion = (HttpClient.Result) -> Void
    private var messages = [(requestedURL: URL, completion: Completion)]()
    
    var requestedURLs: [URL] {
        messages.map { $0.requestedURL }
    }
    
    func get(from url: URL, completion: @escaping Completion) {
        messages.append((url, completion))
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode status: Int, data: Data = Data(), at index: Int = 0) {
        guard let response = HTTPURLResponse(url: requestedURLs[index], statusCode: status, httpVersion: nil, headerFields: nil) else {
            return
        }
        
        messages[index].completion(.success((response, data)))
    }
}

