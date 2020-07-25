//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest

extension XCTestCase {
    
    func trackForMemoryLeak(instance: AnyObject, file: StaticString, line: UInt) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Check For Possible Memory Leak", file: file, line: line)
        }
    }
    
}
