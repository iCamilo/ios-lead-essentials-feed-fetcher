//  Created by Ivan Fuertes on 27/05/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public struct FeedImage: Equatable {
    public private(set) var id: UUID
    public private(set) var url: URL
    public private(set) var description: String?
    public private(set) var location: String?
    
    public init(id: UUID, url: URL, description: String? = nil, location: String? = nil) {
        self.id = id
        self.url = url
        self.description = description
        self.location = location
    }
}
