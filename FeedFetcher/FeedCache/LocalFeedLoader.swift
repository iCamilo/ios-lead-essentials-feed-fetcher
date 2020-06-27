//  Created by Ivan Fuertes on 16/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

final public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
                        
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    public func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed {[weak self] cacheDeletionError in
            guard let self = self else { return }
            
            guard cacheDeletionError == nil else {
                completion(cacheDeletionError)
                return
            }
                                        
            self.cache(feed: feed, with: completion)
        }
    }
    
    private func cache(feed: [FeedImage], with completion: @escaping (Error?) -> Void) {
        store.insert(feed.mapToLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else {return}
            
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        store.retrieveCachedFeed {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):                
                completion(.failure(error))
            
            case let .success( .some(cache) ) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.mapToModel()))
                                    
            case .success:
                completion(.success([]))
            }                        
        }
    }
}
 
extension LocalFeedLoader {
    public func validateCache() {
        store.retrieveCachedFeed {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed {_ in }

            case let .success( .some(cache) ) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed {_ in }
            
            case .success:
                break
            }
        }
    }
}
    
private extension Array where Element == FeedImage {
    func mapToLocal() -> [LocalFeedImage] {
        self.map {
            LocalFeedImage(id: $0.id,
                          url: $0.url,
                          description: $0.description,
                          location: $0.location)            
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func mapToModel() -> [FeedImage] {
        self.map {
            FeedImage(id: $0.id,
                      url: $0.url,
                      description: $0.description,
                      location: $0.location)
        }
    }
}
