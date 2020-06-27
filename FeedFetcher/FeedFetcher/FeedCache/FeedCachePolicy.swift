//  Created by Ivan Fuertes on 19/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

final class FeedCachePolicy {
    static private let calendar = Calendar(identifier: .gregorian)
            
    private init() { }
    
    static private var maxCacheDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let minCacheAge = calendar.date(byAdding: .day, value: -maxCacheDays, to: date) else {
            return false
        }
        
        return timestamp > minCacheAge
    }
    
}
