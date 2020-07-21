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
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                guard let managedCache = try context.fetch(request).first else {
                    return nil
                }
                
                let retrieveResult = managedCache.mapTo()
                return CachedFeed(feed: retrieveResult.feed, timestamp: retrieveResult.timestamp)
            })
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

// MARK:- FeedImageDataStore

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func retrieveImageData(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult)-> Void) {
        perform { [weak self] context in
            let retrieveResult: FeedImageDataStore.RetrieveResult =  Result(catching: {
                let managedImage = try self?.firstFetchManagedImage(for: url, from: context)
                
                return managedImage?.data
            })
            
            completion(retrieveResult)
        }
    }
    
    public func insertImageData(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
        perform { [weak self] context in
            let insertResult: FeedImageDataStore.InsertResult = Result(catching: {
                let managedImage = try self?.firstFetchManagedImage(for: url, from: context)
                managedImage?.data = data
                
                try context.saveIfHasPendingChanges()
                return ()
            })
            
            completion(insertResult)
        }
    }
    
    private func firstFetchManagedImage(for url: URL, from context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let predicate = NSPredicate(format: "url == %@", argumentArray: [url])
        let request = NSFetchRequest<ManagedFeedImage>(entityName: ManagedFeedImage.entity().name!)
                
        request.predicate = predicate
        request.fetchLimit = 1
                        
        return try context.fetch(request).first
    }
    
}
