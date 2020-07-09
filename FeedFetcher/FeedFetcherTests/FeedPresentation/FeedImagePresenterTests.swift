//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest

struct FeedImageViewModel: Equatable {
    
}

final class FeedImagePresenter {
    
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_feedImagePresenter_initDoesNotSendMessaagesToView() {
        let view = FeedImageViewSpy()
        let _ = FeedImagePresenter()
        
        
        XCTAssertEqual(view.messages, [])
    }
    
    class FeedImageViewSpy {
        private(set) var messages = [FeedImageViewModel]()
        
    }
    
}
