//  Created by Ivan Fuertes on 27/05/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
