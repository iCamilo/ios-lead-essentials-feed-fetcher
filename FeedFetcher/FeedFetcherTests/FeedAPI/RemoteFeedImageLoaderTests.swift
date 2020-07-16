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
        httpClient.get(from: url) { result in
            do {
                let (response, _) = try result.get()
                guard response.statusCode == Self.OK_200 else {
                    return completion(.failure(Error.invalidData))
                }
            } catch {
                completion(.failure(Error.connectivity))
            }
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
        let url = anyURL()
        let (sut, httpClient) = makeSUT()
        
        let exp = expectation(description: "Waiting for image load to complete")
        sut.loadImageData(from: url) { response in
            switch response {
            case let .failure(error as RemoteFeedImageLoader.Error):
                XCTAssertEqual(error, .connectivity)
            default:
                XCTFail("Expected connectivity error on http client failure, but got \(response)")
            }
            
            exp.fulfill()
        }
                
        httpClient.complete(withError: anyNSError())
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageData_respondsInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, httpClient) = makeSUT()
        
        let exp = expectation(description: "Waiting for image load to complete")
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(error as RemoteFeedImageLoader.Error):
                XCTAssertEqual(error, .invalidData)
            default:
                XCTFail("Expected invalid ata error on non 200 http response, but got \(result)")
            }
            exp.fulfill()
        }
        
        httpClient.complete(withStatusCode: 199)
        wait(for: [exp], timeout: 1.0)
    }
    
    
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedImageLoader(httpClient: client)
        
        trackForMemoryLeak(instance: client, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return(sut, client)
    }
    
}
