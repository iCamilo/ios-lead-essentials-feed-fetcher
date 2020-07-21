//  Created by Ivan Fuertes on 21/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try CoreDataFeedStore.deleteAllManagedCache(in: context)
                try context.saveIfHasPendingChanges()
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                try CoreDataFeedStore.deleteAllManagedCache(in: context)
                
                ManagedCache.mapFrom((timestamp: timestamp, images: feed), in: context)
                try context.saveIfHasPendingChanges()
            })
        }
    }
    
    public func retrieveCachedFeed(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                guard let managedCache = try Self.fetchFirstManagedCache(from: context) else {
                    return nil
                }
                
                let retrieveResult = managedCache.mapTo()
                return CachedFeed(feed: retrieveResult.feed, timestamp: retrieveResult.timestamp)
            })
        }
    }
    
    private static func deleteAllManagedCache(in context: NSManagedObjectContext) throws {
        try fetchFirstManagedCache(from: context).flatMap { context.delete($0) }
    }
    
    @discardableResult
    private static func fetchFirstManagedCache(from context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        
        return try context.fetch(request).first
    }
    
}
