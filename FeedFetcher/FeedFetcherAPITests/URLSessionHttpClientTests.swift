//  Created by Ivan Fuertes on 1/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import XCTest
import FeedFetcher
import FeedFetcherAPI

class URLSessionHttpClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_requestUsesCorrectURL() {
        let correctURL = anyURL()
        let expectation = self.expectation(description: "Waiting for observing to complete")
                
        var receivedRequest: URLRequest?
        URLProtocolStub.observeRequests { request in
            receivedRequest = request
            
            expectation.fulfill()
        }
       
        makeSUT().get(from: correctURL) { _ in }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedRequest?.url, correctURL)
        XCTAssertEqual(receivedRequest?.httpMethod, "GET")        
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual(requestError, receivedError as NSError?)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let result = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(data, result?.data)
        XCTAssertEqual(response.statusCode, result?.response.statusCode)
        XCTAssertEqual(response.url, result?.response.url)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let emptyData = Data()
        let response = anyHTTPURLResponse()
        let result = resultValuesFor(data: emptyData, response: response, error: nil)
        
        XCTAssertEqual(emptyData, result?.data)
        XCTAssertEqual(response.statusCode, result?.response.statusCode)
        XCTAssertEqual(response.url, result?.response.url)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Waiting for get to complete")
        let task = sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error) where self.isTaskCancelledError(error):
                break
            default:
                XCTFail("Expected cancelled task to not complete, but got \(result)")
            }
            exp.fulfill()
        }
        
        task.cancel()
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    // MARK: - Helpers
        
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HttpClient {
        let sut = URLSessionHttpClient()
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
                    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
            
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        
        var receivedError: Error?
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
        }
        
        return receivedError
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (response: HTTPURLResponse, data: Data)? {
        let result = resultFor(data: data, response: response, error: error)
        
        var receivedResponse: (response: HTTPURLResponse, data: Data)?
        switch result {
        case let .success(response):
            receivedResponse = response
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
        }
        
        return receivedResponse
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HttpClient.Result {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let expectation = self.expectation(description: "Waiting for get to completes")
        
        var receivedResult: HttpClient.Result!
        sut.get(from: anyURL()) { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        return receivedResult
    }
    
    private func isTaskCancelledError(_ error: Error) -> Bool {
        return (error as NSError).domain == "NSURLErrorDomain"
            && (error as NSError).code == -999
    }
            
}

