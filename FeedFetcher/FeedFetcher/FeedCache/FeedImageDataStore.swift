//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public protocol RetrieveImageDataTask {
    func cancel()
}

public protocol FeedImageDataStore {
    typealias RetrieveResult = Swift.Result<Data?,Error>
    typealias InsertResult = Swift.Result<Void,Error>
    
    func retrieveImageData(for url: URL, completion: @escaping (RetrieveResult)-> Void) -> RetrieveImageDataTask
    func insertImageData(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void)
}
