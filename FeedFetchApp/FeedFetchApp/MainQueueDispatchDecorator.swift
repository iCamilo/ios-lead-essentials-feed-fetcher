//  Created by Ivan Fuertes on 9/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatchToMainQueue(action: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: action)
        }
        
        action()
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTask {
        decoratee.loadImageData(from: url) {[weak self] result in
            self?.dispatchToMainQueue { completion(result) }
        }
    }
}
