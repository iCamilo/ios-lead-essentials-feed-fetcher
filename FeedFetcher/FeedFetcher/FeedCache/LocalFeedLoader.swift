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
    public typealias SaveResult = Result<Void, Error>
    
    public func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed {[weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(feed: feed, with: completion)
            case let .failure(cacheDeletionError):
                completion(.failure(cacheDeletionError))
            }                                                            
        }
    }
    
    private func cache(feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.mapToLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else {return}
            
            switch insertionResult {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
            
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
