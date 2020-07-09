//  Created by Ivan Fuertes on 28/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import XCTest
import FeedFetcher
import FeedFetcheriOS

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
                
        let localizedKey = "FEED_VIEW_TITLE"
        XCTAssertEqual(sut.title, localized(key: localizedKey))
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Feed load not expected at controller init")
            
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Feed load expected at controller view did load")
            
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Feed load expected at user initiated feed reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Feed load expected at user initiated feed reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true, "Loading indicator expected to be shown at controller view did load")
    
        loader.completeLoad(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false, "Loading indicator expected to be hidden once feed load completes successfully")
   
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true, "Loading indicator expected to be shown at user initiated feed reload")
    
        loader.completeLoadWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false, "Loading indicator expected to be hidden once feed load completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "another description", location: nil)
        let image2 = makeImage(description: nil, location: "another location")
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assert(sut, isRendering: [])
                
        let singleImage = [image0]
        loader.completeLoad(with: singleImage, at: 0)
        assert(sut, isRendering: singleImage)
                        
        let multipleImages = [image0, image1, image2, image3]
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoad(with: multipleImages, at: 1)
        assert(sut, isRendering: multipleImages)
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0], at: 0)
        assert(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoadWithError(at: 1)
        assert(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImagesURLs, [], "Expected no image URL requests until view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url], "Expected one image request as one cell has become visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url, image1.url], "Expected two image requests as two cells have become visible")
    }
    
    func test_feedImageView_cancelImageURLWhenNotVisible() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImagesURLs, [], "Expected no image URL requests cancelled until view becomes visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImagesURLs, [image0.url], "Expected one image request cancelled as one cell has become not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImagesURLs, [image0.url, image1.url], "Expected two image requests cancelled as both cells have become not visible")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading first image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view as loading first image is completed")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view as image view has not completed yet")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view as loading first image is completed")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view as loading second image is completed")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .green).pngData()!
        loader.completeImageLoading(withImageData: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view as loading first image has completed")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
                
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view as loading first image has completed")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view as loading second image has completed with an error")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(withImageData: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view as loading first image has completed")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view as loading second image has completed")
        
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry button for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected no retry button for second view while loading second image")
               
        let imageData0 = UIImage.make(withColor: .green).pngData()!
        loader.completeImageLoading(withImageData: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry button for first view as loading first image completed successfully")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected no retry button for second view while loading second image")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry button for first view as loading first image completed successfully")
        XCTAssertEqual(view1?.isShowingRetryButton, true, "Expected retry button for second view as loading second image completed with an error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let (sut, loader) = makeSUT()
                
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry button for first view while loading first image")
                
        let invalidData = "Invalid Data".data(using: .utf8)!
        loader.completeImageLoading(withImageData: invalidData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, true, "Expected retry button as loading first image completed successfully BUT with invalid data")
    }
    
    func test_feedImageRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url, image1.url], "Expected only two image URL request before retry action")
                                
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url, image1.url, image0.url], "Expected third image URL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth image URL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImagesURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImagesURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelImageURLPreloadWhenNoNearVisible() {
        let image0 = makeImage(url: URL(string: "http://image0-url.com")!)
        let image1 = makeImage(url: URL(string: "http://image1-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImagesURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImagesURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImagesURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible")
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [makeImage()], at: 0)

        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(withImageData: UIImage.make(withColor: .green).pngData()!, at: 0)

        XCTAssertNil(view.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(id: UUID = UUID(), url: URL = URL(string: "http://any-url.com")!, description: String? = nil, location: String? = nil) -> FeedImage {
        return FeedImage(id: id, url: url, description: description, location: location)
    }
    
    
    
}

// MARK:- UIImage+MakeWithColor

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
}
