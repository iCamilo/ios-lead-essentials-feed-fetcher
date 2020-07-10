//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public  struct FeedViewModel: Equatable {
    let feed: [FeedImage]
    
    public init (feed: [FeedImage]) {
        self.feed = feed
    }
}
