//  Created by Ivan Fuertes on 16/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

struct RemoteFeedItem: Codable {
    var id: UUID
    var image: URL
    var description: String?
    var location: String?
    
    var feedItem: FeedImage {
        return FeedImage(id: id,
                        url: image,
                        description: description,
                        location: location)
    }
}
