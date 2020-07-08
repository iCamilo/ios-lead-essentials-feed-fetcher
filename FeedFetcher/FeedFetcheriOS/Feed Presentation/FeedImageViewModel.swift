//  Created by Ivan Fuertes on 3/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

struct FeedImageViewModel<Image> {
    var image: Image?
    var location: String?
    var description: String?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool { location != .none }
}
