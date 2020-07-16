//  Created by Ivan Fuertes on 15/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

final class RemoteFeedImageLoader {
    typealias Result = Swift.Result<Data, Swift.Error>
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    private let OK_200 = 200
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataTask {
        let task = RemoteFeedImageTask()
        task.wrappedHttpTask = httpClient.get(from: url) { [weak self] httpResult in
            guard let self = self else {
                return
            }
            
            let result = self.handle(httpResult: httpResult)
            completion(result)
        }
        
        return task
    }

    private func handle(httpResult: HttpClient.Result) -> RemoteFeedImageLoader.Result {
        return httpResult
            .mapError { _ in Error.connectivity}
            .flatMap ({ (response, data) in
                let isValidResponse = self.isValid((response, data))
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
    }
    
    private func isValid(_ result: (response: HTTPURLResponse, data: Data)) -> Bool {
        return result.response.statusCode == OK_200 && !result.data.isEmpty
    }
    
    private class RemoteFeedImageTask: FeedImageDataTask {
        var wrappedHttpTask: HttpClientTask?
        
        func cancel() {
            wrappedHttpTask?.cancel()
        }
    }

}

class RemoteFeedImageLoaderTests: XCTestCase {
        
    func test_init_doesNotRequestData() {
        let (_, httpClient) = makeSUT()
                        
        XCTAssertEqual(httpClient.requestedURLs, [])
    }
    
    func test_loadImageData_requestDataFromURL() {
        let url = anyURL()
        let (sut, httpClient) = makeSUT()
        
        sut.loadImageData(from: url) {_ in}
        
        XCTAssertEqual(httpClient.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestDataFromURLTwice() {
        let url = anyURL()
        let (sut, httpClient) = makeSUT()
        
        sut.loadImageData(from: url) {_ in}
        sut.loadImageData(from: url) {_ in}
        
        XCTAssertEqual(httpClient.requestedURLs, [url, url])
    }
    
    func test_loadImageData_respondsWithConnectivityErrorOnClientError() {        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            httpClient.complete(withError: anyNSError())
        })
    }
    
    func test_loadImageData_respondsInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, httpClient) = makeSUT()
        let samples = [199, 201, 400, 500]
        
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                httpClient.complete(withStatusCode: statusCode, at: index)
            })
        }
    }
    
    func test_loadImageData_respondsInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, httpClient) = makeSUT()
        let emptyData = Data()
                
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            httpClient.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageData_respondsWithDataOn200HTTPResponseWithNonEmptyData() {
        let (sut, httpClient) = makeSUT()
        let nonEmptyData = "nonEmptyData".data(using: .utf8)!
                
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            httpClient.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_loadImageData_doesNotCompleteAfterLoaderDeallocation() {
        let httpClient = HttpClientSpy()
        var sut: RemoteFeedImageLoader? = RemoteFeedImageLoader(httpClient: httpClient)
                
        sut?.loadImageData(from: anyURL()) { result in
            XCTFail("Load image data should not complete after loader has been deallocated")
        }
        
        sut = nil
        httpClient.complete(withStatusCode: 200)
    }
    
    func test_cancelLoadImageDataTask_cancelClientRequest() {
        let (sut, httpClient) = makeSUT()
        let aURL = anyURL()
                
        let task = sut.loadImageData(from: aURL) { _ in }
        XCTAssertTrue(httpClient.cancelledRequests.isEmpty, "Expected no cancelled url request before task is cancelled")
        
        task.cancel()
        XCTAssertEqual(httpClient.cancelledRequests, [aURL], "Expected cancelled url request after task is cancelled")
    }
            
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedImageLoader(httpClient: client)
        
        trackForMemoryLeak(instance: client, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return(sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageLoader, toCompleteWith expected: RemoteFeedImageLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for image load to complete")
        
        sut.loadImageData(from: anyURL()) { result in
            switch (expected, result) {
            case let (.failure(expectedError as RemoteFeedImageLoader.Error), .failure(receivedError as RemoteFeedImageLoader.Error)):
                XCTAssertEqual(expectedError, receivedError, "Expected \(expectedError) but got \(receivedError)", file: file, line: line)
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, "Expected to receive data \(expectedData) but got \(receivedData)", file: file, line: line)
            default:
                XCTFail("Expected \(expected) but got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedImageLoader.Error) -> RemoteFeedImageLoader.Result {
        return .failure(error)
    }
}
