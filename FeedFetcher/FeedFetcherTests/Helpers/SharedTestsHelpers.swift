//  Created by Ivan Fuertes on 19/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "test", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any-data".utf8)
}

