//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieveImageData(URL)
        case cancelRetrieval(URL)
        case insertImageData(Data)
    }
        
    private let storeError = NSError(domain: "ImageDataStore", code: 0)
    private(set) var messages = [Message]()
    
    // MARK:- retrieveImageData
    
    private(set) var retrieveCompletions = [(FeedImageDataStore.RetrieveResult) -> Void]()
    
    func retrieveImageData(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult)-> Void) -> RetrieveImageDataTask {
        messages.append(.retrieveImageData(url))
        retrieveCompletions.append(completion)
        
        return RetrieveTask ({ [weak self] in
            self?.messages.append(.cancelRetrieval(url))
        })
    }
    
    func completeRetrievalWithError(at index: Int = 0) {
        retrieveCompletions[index](.failure(storeError))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        let emptyData = Data()
        retrieveCompletions[index](.success(emptyData))
    }
    
    func completeRetrievalWith(data: Data?, at index: Int = 0) {
        retrieveCompletions[index](.success(data))
    }
    
    // MARK:- insertImageData
    
    private(set) var insertCompletions = [(FeedImageDataStore.InsertResult) -> Void]()
    
    func insertImageData(_ data: Data, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
        messages.append(.insertImageData(data))
        insertCompletions.append(completion)
    }
    
    func completeInsertionWithError(at index: Int = 0) {
        insertCompletions[index](.failure(storeError))
    }
    
    func completeInsertionWith(data: Data, at index: Int = 0) {
        insertCompletions[index](.success(()))
    }
    
    // MARK:- RetrieveImageDataTask
    
    private struct RetrieveTask: RetrieveImageDataTask {
        private let callback: () -> Void
        
        init(_ callback: @escaping () -> Void) {
            self.callback = callback
        }
        
        func cancel() {
            callback()
        }
    }
}
