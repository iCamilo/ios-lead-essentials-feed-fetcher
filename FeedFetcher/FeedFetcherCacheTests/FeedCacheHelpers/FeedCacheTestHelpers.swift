//  Created by Ivan Fuertes on 19/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher
import FeedFetcherCache

func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let imageFeed = [uniqueImage(), uniqueImage()]
    let localFeed = imageFeed.map { LocalFeedImage(id: $0.id,
                                               url: $0.url,
                                               description: $0.description,
                                               location: $0.location) }
    
    return (imageFeed, localFeed)
}

extension Date {
    private var maxCacheDays: Int {
        return 7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return self.adding(days: -maxCacheDays)
    }
                
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
