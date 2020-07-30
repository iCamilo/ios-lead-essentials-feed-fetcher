//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher
import FeedFetcherCache

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieveImageData(URL)        
        case insertImageData(Data, for: URL)
    }
        
    private let storeError = NSError(domain: "ImageDataStore", code: 0)
    private(set) var messages = [Message]()
    
    // MARK:- retrieveImageData
    
    private(set) var retrieveCompletions = [(FeedImageDataStore.RetrieveResult) -> Void]()
    
    func retrieveImageData(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult)-> Void) {
        messages.append(.retrieveImageData(url))
        retrieveCompletions.append(completion)
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
    
    func insertImageData(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
        messages.append(.insertImageData(data, for: url))
        insertCompletions.append(completion)
    }
    
    func completeInsertionWithError(at index: Int = 0) {
        insertCompletions[index](.failure(storeError))
    }
    
    func completeInsertionWith(data: Data, at index: Int = 0) {
        insertCompletions[index](.success(()))
    }
    
}
