//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest

struct FeedLoadingViewModel: Equatable {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}


final class FeedPresenter {
    private let loadingView: FeedLoadingView
    
    init(loadingView: FeedLoadingView) {
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Presenter init should not send any messages to the view")
    }
    
    func test_didStartLoading_sendsMessageDisplayLoadingView() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.loading(FeedLoadingViewModel(isLoading: true))])
    }
            
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: FeedViewSpy){
        let view = FeedViewSpy()
        let sut = FeedPresenter(loadingView: view)
                
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: view, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private class FeedViewSpy: FeedLoadingView {
        enum Message: Equatable {
            case loading(FeedLoadingViewModel)
        }
                
        private(set) var messages = [Message]()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.loading(viewModel))
        }
        
    }
    
}
