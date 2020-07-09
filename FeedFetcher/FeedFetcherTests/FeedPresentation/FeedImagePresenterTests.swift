//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

struct FeedImageViewModel<Image> {
    var image: Image?
    var location: String?
    var description: String?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool { location != .none }
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            image: nil,
            location: model.location,
            description: model.description,
            isLoading: true,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(
            image: nil,
            location: model.location,
            description: model.description,
            isLoading: false,
            shouldRetry: true))
    }
    
    
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages at init")
    }
    
    func test_startLoadingImageData_displaysImageViewIsLoading() {
        let (sut, view) = makeSUT()
        let anyImage = uniqueImage()
        
        sut.didStartLoadingImageData(for: anyImage)
        
        guard let viewModel = view.messages.first else {
            return XCTFail("View Model expected not to be nil")
        }
        
        XCTAssertNil(viewModel.image)
        XCTAssertEqual(anyImage.location, viewModel.location)
        XCTAssertEqual(anyImage.description, viewModel.description)
        XCTAssertTrue(viewModel.isLoading, "View model isLoading should be true if image data has starting loading")
        XCTAssertFalse(viewModel.shouldRetry, "View model should retry should be false if image data has starting loading")
    }
    
    func test_didFinishLoadingWithError_displaysImageViewShouldRetry() {
        let (sut, view) = makeSUT()
        let anyImage = uniqueImage()
        let anyError = anyNSError()
        
        sut.didFinishLoadingImageData(with: anyError, for: anyImage)
        
        guard let viewModel = view.messages.first else {
            return XCTFail("View Model expected not to be nil")
        }
        
        XCTAssertNil(viewModel.image)
        XCTAssertEqual(anyImage.location, viewModel.location)
        XCTAssertEqual(anyImage.description, viewModel.description)
        XCTAssertFalse(viewModel.isLoading, "View model isLoading should be false if image data load did finish")
        XCTAssertTrue(viewModel.shouldRetry, "View model should retry should be true if loaded image data is not valid")
    }
    
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<FeedImageViewSpy, AnyImage>, View: FeedImageViewSpy) {
        let view = FeedImageViewSpy()
        let sut = FeedImagePresenter<FeedImageViewSpy, AnyImage>(view: view)
        
        trackForMemoryLeak(instance: view, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private struct AnyImage: Equatable {}
    
    private class FeedImageViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
    
}
