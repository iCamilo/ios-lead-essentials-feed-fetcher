//  Created by Ivan Fuertes on 28/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import XCTest
import FeedFetcher
import FeedFetcheriOS

class FeedViewControllerTests: XCTestCase {
    
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
        XCTAssertEqual(loader.cancelledImagesURLs, [image0.url], "Expected one image request as one cell has become visible")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImagesURLs, [image0.url, image1.url], "Expected two image requests as two cells have become visible")
    }
    
    
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(id: UUID = UUID(), url: URL = URL(string: "http://any-url.com")!, description: String? = nil, location: String? = nil) -> FeedImage {
        return FeedImage(id: id, url: url, description: description, location: location)
    }
    
    private func assert(_ sut: FeedViewController, isRendering feed:[FeedImage], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedImagesView(), feed.count, "Expected to render a total of \(feed.count) image views")
        
        feed.enumerated().forEach{ index, image in
            assertFeedImageViewHasBeenConfigured(for: sut, with: image, at: index, file: file, line: line)
        }
    }
    
    private func assertFeedImageViewHasBeenConfigured(for sut: FeedViewController, with image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, BUT GOT \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing:image.location)) at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing:image.description)) at index \(index)", file: file, line: line)
    }
        
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: FeedLoader
        
        private var feedRequests = [ (FeedLoader.Result) -> Void ]()
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeLoad(with feed:[FeedImage] = [], at index: Int) {
            feedRequests[index](.success(feed))
        }
        
        func completeLoadWithError(at index: Int) {
            feedRequests[index](.failure(anyNSError()))
        }
        
        // MARK: FeedImageDataLoader
        
        private(set) var loadedImagesURLs = [URL]()
        private(set) var cancelledImagesURLs = [URL]()
        
        func loadImageData(from url: URL) {
            loadedImagesURLs.append(url)
        }
        
        func cancelImageDataLoad(from url: URL) {
            cancelledImagesURLs.append(url)
        }
        
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at index: Int) {
        let view = simulateFeedImageViewVisible(at: index)!
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: indexPath)
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImagesView() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
