//  Created by Ivan Fuertes on 2/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public class URLSessionHttpClient: HttpClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesError: Error { }
    
    public func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let response = response as? HTTPURLResponse
            else {
                completion(.failure(UnexpectedValuesError()))
                return
            }
            
            completion(.success((response,data)))
        }.resume()
    }
}
