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
    
    private static let OK_200 = 200
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) {
        httpClient.get(from: url) { response in
            do {
                let response = try response.get()
                guard Self.isValid(response) else {
                    return completion(.failure(Error.invalidData))
                }
            } catch {
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func isValid(_ response: (response: HTTPURLResponse, data: Data)) -> Bool {
        return response.response.statusCode == OK_200 && !response.data.isEmpty
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
