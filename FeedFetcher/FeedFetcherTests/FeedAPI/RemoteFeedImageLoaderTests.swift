//  Created by Ivan Fuertes on 15/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

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
        let nonEmptyData = anyData()
                
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
    
    func test_loadImageData_doesNotCompleteAfterCancellingTask() {
        let (sut, httpClient) = makeSUT()
        let aURL = anyURL()
                    
        let task = sut.loadImageData(from: aURL) { result in
            XCTFail("Expected load to not complete as the task was cancelled")
        }
        
        task.cancel()
        httpClient.complete(withError: anyNSError())
        httpClient.complete(withStatusCode: 404, data: anyData())
        httpClient.complete(withStatusCode: 200, data: anyData())
    }
            
    // MARK:- Helpers
         
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedImageLoader(httpClient: client)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: client, file: file, line: line)
        
        return(sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageLoader, toCompleteWith expected: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
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
