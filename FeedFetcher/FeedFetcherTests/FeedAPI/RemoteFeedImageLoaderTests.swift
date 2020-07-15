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
    
}

class RemoteFeedImageLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let httpClient = HttpClientSpy()
        let _ = RemoteFeedImageLoader(httpClient: httpClient)
                
        XCTAssertEqual(httpClient.imageURLs, [])
    }
    

    // MARK:- Helpers
    
    private class HttpClientSpy: HttpClient {
        private(set) var imageURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
            
        }
    }
    
}
