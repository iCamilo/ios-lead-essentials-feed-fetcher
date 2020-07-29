//  Created by Ivan Fuertes on 8/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcheriOS
import FeedFetcher

extension FeedUIIntegrationTests {
    func assert(_ sut: FeedViewController, isRendering feed:[FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        
        XCTAssertEqual(sut.numberOfRenderedFeedImagesView(), feed.count, "Expected to render a total of \(feed.count) image views", file: file, line: line)
        
        feed.enumerated().forEach{ index, image in
            assertFeedImageViewHasBeenConfigured(for: sut, with: image, at: index, file: file, line: line)
        }
    }
        
    func assertFeedImageViewHasBeenConfigured(for sut: FeedViewController, with image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, BUT GOT \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing:image.location)) at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing:image.description)) at index \(index)", file: file, line: line)
    }    
}
