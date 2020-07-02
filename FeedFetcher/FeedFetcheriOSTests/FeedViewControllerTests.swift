//  Created by Ivan Fuertes on 28/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import XCTest
import FeedFetcher
import FeedFetcheriOS

class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCounter, 0, "Feed load not expected at controller init")
            
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCounter, 1, "Feed load expected at controller view did load")
            
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCounter, 2, "Feed load expected at user initiated feed reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCounter, 3, "Feed load expected at user initiated feed reload")
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
    
    
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(id: UUID = UUID(), url: URL = URL(string: "http://any-url.com")!, description: String?, location: String?) -> FeedImage {
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
        
    class LoaderSpy: FeedLoader {
        private var completions = [ (FeedLoader.Result) -> Void ]()
        var loadCallCounter: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLoad(with feed:[FeedImage] = [], at index: Int) {
            completions[index](.success(feed))
        }
        
        func completeLoadWithError(at index: Int) {
            completions[index](.failure(anyNSError()))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
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
