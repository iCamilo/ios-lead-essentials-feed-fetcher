//  Created by Ivan Fuertes on 18/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import XCTest

protocol FeedImageDataStore {}

final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
}

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_feedImageDataStore_doesNotRequestDataAtInit() {
        let store = DataStoreSpy()
        let _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertEqual(store.messages, [])
    }
    
}

// MARK: - DataStoreSpy

private class DataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {}
    
    private(set) var messages = [Message]()
}
