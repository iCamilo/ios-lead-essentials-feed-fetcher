//  Created by Ivan Fuertes on 25/06/20.
//  Copyright © 2020 Essential Developer. All rights reserved.

import CoreData

@objc(ManagedFeedImage)
final class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    static func mapFrom(_ localImage: LocalFeedImage, in context: NSManagedObjectContext) -> ManagedFeedImage {
        let managed = ManagedFeedImage(context: context)
        managed.id = localImage.id
        managed.url = localImage.url
        managed.imageDescription = localImage.description
        managed.location = localImage.description
        
        return managed
    }
        
    func mapTo() -> LocalFeedImage {
        return LocalFeedImage(id: id,
                              url: url,
                              description: imageDescription,
                              location: location)
    }
}
