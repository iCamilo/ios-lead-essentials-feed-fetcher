//  Created by Ivan Fuertes on 20/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        var feed: [CodableFeedImage]
        var timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let url: URL
        private let description: String?
        private let location: String?
        
        init(_ image: LocalFeedImage) {
            id = image.id
            url = image.url
            description = image.description
            location = image.location
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, url: url, description: description, location: location)
        }
    }
         
    private let codableFeedStoreQueue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", attributes: .concurrent)
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieveCachedFeed(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        
        codableFeedStoreQueue.async {
            guard let decodedData = try? Data(contentsOf: storeURL) else {
                return completion(.success(nil))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: decodedData)
                
                completion(.success( CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)  ))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        
        codableFeedStoreQueue.async(flags: .barrier) {
            do {
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(cache)
                
                try encoded.write(to: storeURL)
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        
        codableFeedStoreQueue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
}
