//  Created by Ivan Fuertes on 28/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher
import FeedFetcherAPI

class HTTPClientStub: HttpClient {
    private class Task: HttpClientTask {
        func cancel() {}
    }

    private let stub: (URL) -> HttpClient.Result

    init(stub: @escaping (URL) -> HttpClient.Result) {
        self.stub = stub
    }

    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(stub(url))
        return Task()
    }
}

extension HTTPClientStub {
    static var offline: HTTPClientStub {
        HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }

    static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }
    
}
