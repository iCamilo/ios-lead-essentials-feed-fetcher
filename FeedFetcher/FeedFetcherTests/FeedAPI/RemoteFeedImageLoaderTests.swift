//  Created by Ivan Fuertes on 15/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

final class RemoteFeedImageLoader {
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func loadImageData(from url: URL) {
        httpClient.get(from: url) { _ in }
    }
}

class RemoteFeedImageLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, httpClient) = makeSUT()
                        
        XCTAssertEqual(httpClient.imageURLs, [])
    }
    
    func test_loadImageData_requestDataFromURL() {
        let url = anyURL()
        let (sut, httpClient) = makeSUT()
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(httpClient.imageURLs, [url])
    }
    

    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedImageLoader(httpClient: client)
        
        trackForMemoryLeak(instance: client, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return(sut, client)
    }
    
    private class HttpClientSpy: HttpClient {
        private(set) var imageURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
            imageURLs.append(url)
        }
    }
    
}
