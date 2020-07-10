//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

struct FeedLoadingViewModel: Equatable {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel: Equatable {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}


final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
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
    
    func test_didFinishLoadingWithError_sendsMessageHideLoadingView() {
        let (sut, view) = makeSUT()
        let anyError = anyNSError()
        
        sut.didFinishLoadingFeed(with: anyError)
        
        XCTAssertEqual(view.messages, [.loading(FeedLoadingViewModel(isLoading: false))])
    }
    
    func test_didFinishLoadingWithFeed_sendsHideLoadingViewAndDisplayFeedView() {
        let (sut, view) = makeSUT()
        let anyFeed = [uniqueImage(), uniqueImage()]
        
        sut.didFinishLoadingFeed(with: anyFeed)
        
        XCTAssertEqual(view.messages, [ .displaying(FeedViewModel(feed: anyFeed)),
                                        .loading(FeedLoadingViewModel(isLoading: false)) ])
    }
            
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: FeedViewSpy){
        let view = FeedViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view)
                
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: view, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private class FeedViewSpy: FeedLoadingView, FeedView {
        enum Message: Equatable {
            case loading(FeedLoadingViewModel)
            case displaying(FeedViewModel)
        }
                
        private(set) var messages = [Message]()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.loading(viewModel))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.append(.displaying(viewModel))
        }
        
    }
    
}
