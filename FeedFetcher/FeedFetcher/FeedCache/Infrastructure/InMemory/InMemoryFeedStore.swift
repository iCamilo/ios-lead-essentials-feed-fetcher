//  Created by Ivan Fuertes on 21/06/20.
//  Copyright © 2020 Essential Developer. All rights reserved.

import Foundation

public final class InMemoryFeedStore: FeedStore {
    
    private let queue = DispatchQueue(label: "\(InMemoryFeedStore.self)Queue", attributes: .concurrent)
    
    private var cache: (feed: [LocalFeedImage], timestamp: Date)?
    
    public init() { }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            self.cache = nil
            completion(.success(()))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            self.cache = (feed, timestamp)
            completion(.success(()))
        }
    }
    
    public func retrieveCachedFeed(completion: @escaping RetrievalCompletion) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            guard let cache = self.cache else {
                return completion(.success(nil))
            }
            
            completion(.success( CachedFeed(feed: cache.feed, timestamp: cache.timestamp) ))
        }
    }
}
