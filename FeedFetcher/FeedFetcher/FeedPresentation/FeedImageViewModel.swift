//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public struct FeedImageViewModel<Image> {
    public var image: Image?
    public var location: String?
    public var description: String?
    public var isLoading: Bool
    public var shouldRetry: Bool
    
    public var hasLocation: Bool { location != .none }
}
