//  Created by Ivan Fuertes on 27/05/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
