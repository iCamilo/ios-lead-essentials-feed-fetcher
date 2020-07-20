//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

// MARK:-loadImageData

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        let task = ImageDataLoadTask(completion: completion)
        
        task.wrappedTask =  store.retrieveImageData(for: url) { [weak self] retrieveResult in
            guard let self = self else { return }
            
            let loadResult = self.handle(storeRetrieveResult: retrieveResult)
            task.complete(with: loadResult)
        }
        
        return task
    }
    
    private func handle(storeRetrieveResult retrieveResult: FeedImageDataStore.RetrieveResult) -> FeedImageDataLoader.Result {
        return retrieveResult
            .mapError{ _ in LoadError.failed}
            .flatMap{ data in
                if let data = data {
                    return .success(data)
                } else {
                    return .failure(LoadError.notFound)
                }
            }                
    }
    
    // MARK: ImageDataLoadTask
    
    private class ImageDataLoadTask: FeedImageDataTask {
        private var completion: ((LocalFeedImageDataLoader.Result) -> Void)?
        var wrappedTask: RetrieveImageDataTask?
        
        init(completion: @escaping (LocalFeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            wrappedTask?.cancel()
            invalidateCompletion()
        }
        
        func complete(with result: LocalFeedImageDataLoader.Result) {
            completion?(result)
        }
        
        private func invalidateCompletion() {
            completion = nil
        }
    }
}

// MARK:- saveImageData

public extension LocalFeedImageDataLoader {
    typealias SaveResult = Swift.Result<Void,SaveError>
    
    enum SaveError: Swift.Error {
        case failed        
    }
    
    func saveImageData(_ data: Data, completion: @escaping (SaveResult) -> Void) {
        store.insertImageData(data) { [weak self] insertResult in
            if self == nil { return }
            
            let result: SaveResult = insertResult.mapError { _ in SaveError.failed }
            
            completion(result)
        }
    }
}
