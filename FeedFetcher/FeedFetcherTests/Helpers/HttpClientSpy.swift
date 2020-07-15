//  Created by Ivan Fuertes on 15/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

class HttpClientSpy: HttpClient {
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
