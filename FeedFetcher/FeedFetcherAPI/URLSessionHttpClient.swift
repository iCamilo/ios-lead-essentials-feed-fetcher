//  Created by Ivan Fuertes on 2/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public final class URLSessionHttpClient: HttpClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesError: Error { }
            
    public func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        let task = URLSessionTask()
        task.wrappedTask = session.dataTask(with: url) { (data, response, error) in
            completion(Result {
                if let error = error {
                    throw error
                }
                guard let data = data,
                      let response = response as? HTTPURLResponse
                else {
                    throw UnexpectedValuesError()                    
                }
                
                return (response,data)
            })
        }
        
        task.wrappedTask?.resume()
        return task
    }
}

// MARK:- URLSessionTask

private class URLSessionTask: HttpClientTask {
    var wrappedTask: URLSessionDataTask?
    
    func cancel() {
        wrappedTask?.cancel()
    }
}
