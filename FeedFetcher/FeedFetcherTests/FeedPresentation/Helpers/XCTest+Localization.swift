//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

extension XCTest {
    func localized(key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        
        if value == key {
            XCTFail("Missing localization value for key \(key)", file: file, line: line)
        }
        
        return value
    }
}
