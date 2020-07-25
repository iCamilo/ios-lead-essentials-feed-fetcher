//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
