//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public struct FeedLoadingViewModel: Equatable {
    let isLoading: Bool
    
    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
}
