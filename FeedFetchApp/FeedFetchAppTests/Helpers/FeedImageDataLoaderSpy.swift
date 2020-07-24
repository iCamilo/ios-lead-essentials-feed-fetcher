//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

final class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private(set) var completions = [(FeedImageDataLoader.Result) -> Void]()
    private(set) var cancelledUrls = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        completions.append(completion)
        return Task(callback: { [weak self] in
            self?.cancelledUrls.append(url)
        })
    }
            
    func complete(with error: NSError, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        completions[index](.success(data))
    }
    
    private struct Task: FeedImageDataTask {
        let callback: () -> Void
                        
        func cancel() { callback() }
    }
}
