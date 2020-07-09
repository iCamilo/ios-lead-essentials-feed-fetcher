//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest

struct FeedImageViewModel<Image> {
    var image: Image?
    var location: String?
    var description: String?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool { location != .none }
}

final class FeedImagePresenter {
    
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages at init")
    }
    
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, View: FeedImageViewSpy) {
        let view = FeedImageViewSpy()
        let sut = FeedImagePresenter()
        
        trackForMemoryLeak(instance: view, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private struct AnyImage: Equatable {}
    
    private class FeedImageViewSpy {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
    }
    
}
