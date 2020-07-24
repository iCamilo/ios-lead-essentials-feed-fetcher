//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

var anyURL: URL { return URL(string: "http://any-url.com")! }
var anyError: NSError { return NSError(domain: "FeedLoaderCompositeTest", code: 0) }
var anyData: Data { return "anydata".data(using: .utf8)! }

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), url: anyURL, description: "anyDescription", location:"anyLocation")]
}
