//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public protocol RetrieveImageDataTask {
    func cancel()
}

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data,Error>
    
    func retrieveImageData(for url: URL, completion: @escaping (Result)-> Void) -> RetrieveImageDataTask
}
