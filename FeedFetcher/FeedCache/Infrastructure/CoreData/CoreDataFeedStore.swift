//  Created by Ivan Fuertes on 23/06/20.
//  Copyright © 2020 Essential Developer. All rights reserved.

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let modelName = "FeedStore"
                
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
        
    public init(bundle: Bundle = .main, storeURL: URL) throws {
        container = try NSPersistentContainer.load(modelName: modelName, in: bundle, storeURL: storeURL)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try CoreDataFeedStore.deleteAllManagedCache(in: context)
                try context.saveIfHasPendingChanges()
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                try CoreDataFeedStore.deleteAllManagedCache(in: context)
                
                ManagedCache.mapFrom((timestamp: timestamp, images: feed), in: context)
                try context.saveIfHasPendingChanges()
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieveCachedFeed(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                guard let managedCache = try context.fetch(request).first else {
                    return completion(.empty)
                }
                
                let retrieveResult = managedCache.mapTo()
                
                completion(.success(feed: retrieveResult.feed, timestamp: retrieveResult.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action:@escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
            
    private static func deleteAllManagedCache(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        let caches = try context.fetch(request)
        
        _ = caches.map { context.delete($0) }
    }
}
