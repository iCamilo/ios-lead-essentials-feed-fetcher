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
            
    func perform(_ action:@escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
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
