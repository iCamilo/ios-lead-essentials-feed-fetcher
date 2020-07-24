//  Created by Ivan Fuertes on 24/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest
import FeedFetcher

final class FeedLoaderCacheDecorator: FeedLoader {
        
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
        
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSucess() {
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
                        
        expect(sut, toCompleteFeedLoadWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loaderError = anyError
        let loader = FeedLoaderStub(result: .failure(loaderError))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
                        
        expect(sut, toCompleteFeedLoadWith: .failure(loaderError))
    }
    
    
}
