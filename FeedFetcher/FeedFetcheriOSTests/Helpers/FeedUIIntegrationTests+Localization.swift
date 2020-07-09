//  Created by Ivan Fuertes on 8/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import  FeedFetcheriOS

extension FeedUIIntegrationTests {
    func localized(key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        
        if value == key {
            XCTFail("Missing localization value for key \(key)", file: file, line: line)
        }
        
        return value
    }
}
