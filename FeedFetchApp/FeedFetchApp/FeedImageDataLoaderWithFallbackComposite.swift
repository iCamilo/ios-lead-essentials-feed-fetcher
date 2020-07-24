//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
            
    public init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        let task = LoadImageTask()
        task.wrappedTask = primaryLoader.loadImageData(from: url) {[weak self] primaryResult in
            if case .success = primaryResult {
                return completion(primaryResult)
            }
            
            task.wrappedTask = self?.fallbackLoader.loadImageData(from: url, completion: completion)
        }
        
        return task
    }
    
    private final class LoadImageTask: FeedImageDataTask {
        var wrappedTask: FeedImageDataTask?
        
        func cancel() {
            wrappedTask?.cancel()
        }
    }
    
}
