//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primaryFeedLoader: FeedLoader
    private let fallbackFeedLoader: FeedLoader
    
    public init(primaryFeedLoader: FeedLoader, fallbackFeedLoader: FeedLoader) {
        self.primaryFeedLoader = primaryFeedLoader
        self.fallbackFeedLoader = fallbackFeedLoader
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryFeedLoader.load { primaryResult in
            if case .success = primaryResult {
                return completion(primaryResult)
            }
            
            self.fallbackFeedLoader.load { fallbackResult in
                completion(fallbackResult)
            }
        }
    }
}
