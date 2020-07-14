//  Created by Ivan Fuertes on 8/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher
import FeedFetcheriOS

class LoaderSpy: FeedLoader {            
    private var feedRequests = [ (FeedLoader.Result) -> Void ]()
    
    private(set) var cancelledImagesURLs = [URL]()
    private(set) var loadImagesRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    var loadedImagesURLs: [URL] { return loadImagesRequests.map { $0.url } }
    
    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeLoad(with feed:[FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeLoadWithError(at index: Int) {
        feedRequests[index](.failure(anyNSError()))
    }
}
        
extension LoaderSpy: FeedImageDataLoader {
    private struct DataTaskSpy: FeedImageDataTask {
        let cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
                    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void ) -> FeedImageDataTask {
        loadImagesRequests.append((url: url, completion: completion))
        return DataTaskSpy { [weak self] in
            self?.cancelledImagesURLs.append(url)
        }
    }
    
    func completeImageLoading(withImageData data: Data = Data(), at index: Int) {
        loadImagesRequests[index].completion(.success(data))
    }
    
    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "An Error", code: 0)
        loadImagesRequests[index].completion(.failure(error))
    }
}
