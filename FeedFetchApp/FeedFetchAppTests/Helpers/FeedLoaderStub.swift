//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

final class FeedLoaderStub: FeedLoader {
    
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
        
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
    
}
