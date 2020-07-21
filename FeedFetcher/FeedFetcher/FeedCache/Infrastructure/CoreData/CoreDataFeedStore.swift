//  Created by Ivan Fuertes on 23/06/20.
//  Copyright © 2020 Essential Developer. All rights reserved.

import Foundation
import CoreData

public final class CoreDataFeedStore {
    private let modelName = "FeedStore"
                
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
        
    public init(bundle: Bundle = .main, storeURL: URL) throws {
        container = try NSPersistentContainer.load(modelName: modelName, in: bundle, storeURL: storeURL)
        context = container.newBackgroundContext()
    }
            
    private func perform(_ action:@escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
                
}

// MARK:- FeedStore

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

// MARK:- FeedImageDataStore

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func retrieveImageData(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult)-> Void) {
        perform { context in
            let retrieveResult: FeedImageDataStore.RetrieveResult =  Result(catching: {
                let managedImage = try Self.fetchFirstManagedImage(for: url, from: context)
                
                return managedImage?.data
            })
            
            completion(retrieveResult)
        }
    }
    
    public func insertImageData(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
        perform { context in
            let insertResult: FeedImageDataStore.InsertResult = Result(catching: {
                let managedImage = try Self.fetchFirstManagedImage(for: url, from: context)
                managedImage?.data = data
                
                try context.saveIfHasPendingChanges()
                return ()
            })
            
            completion(insertResult)
        }
    }
    
    private static func fetchFirstManagedImage(for url: URL, from context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let predicate = NSPredicate(format: "url == %@", argumentArray: [url])
        let request = NSFetchRequest<ManagedFeedImage>(entityName: ManagedFeedImage.entity().name!)
                
        request.predicate = predicate
        request.fetchLimit = 1
                        
        return try context.fetch(request).first
    }
    
}
