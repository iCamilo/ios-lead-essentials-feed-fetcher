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

