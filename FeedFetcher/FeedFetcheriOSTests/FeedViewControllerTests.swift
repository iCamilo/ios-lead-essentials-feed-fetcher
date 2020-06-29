//  Created by Ivan Fuertes on 28/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import XCTest
import FeedFetcher

class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
    
}

class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCounter, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCounter, 1)
    }
    
    // MARK:- Helpers
    
    class LoaderSpy {
        private(set) var loadCallCounter: Int = 0
        
        func load() {
            loadCallCounter += 1
        }
    }
}
