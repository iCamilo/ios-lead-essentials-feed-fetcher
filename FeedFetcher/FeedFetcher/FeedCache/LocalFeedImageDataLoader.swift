//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public protocol FeedImageDataLoadTask {
    func cancel()
}

public final class LocalFeedImageDataLoader {
    public typealias Result = Swift.Result<Data, Error>
    public enum Error: Swift.Error {
        case loadingImageData
        case savingImageData
        case notFound
    }
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
        
    public func loadImageData(for url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoadTask {
        let task = ImageDataLoadTask(completion: completion)
        
        task.wrappedTask =  store.retrieveImageData(for: url) { [weak self] retrieveResult in
            guard let self = self else { return }
            
            let loadResult = self.handle(storeRetrieveResult: retrieveResult)
            task.complete(with: loadResult)
        }
        
        return task
    }
    
    private func handle(storeRetrieveResult retrieveResult: FeedImageDataStore.Result) -> LocalFeedImageDataLoader.Result {
        let loadResult = retrieveResult
            .mapError{ _ in Error.loadingImageData}
            .flatMap{ data in
                return !data.isEmpty ? .success(data) :.failure(.notFound)
            }
        
        return loadResult
    }
    
    // MARK:- ImageDataLoadTask
    
    private class ImageDataLoadTask: FeedImageDataLoadTask {
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

public extension LocalFeedImageDataLoader {
    typealias SaveResult = Swift.Result<Void,Error>
    
    func saveImageData(_ data: Data, completion: @escaping (SaveResult) -> Void) {
        store.insertImageData(data) { insertResult in
            let result: SaveResult = insertResult.mapError { _ in Error.savingImageData }
            
            completion(result)
        }
    }
}
