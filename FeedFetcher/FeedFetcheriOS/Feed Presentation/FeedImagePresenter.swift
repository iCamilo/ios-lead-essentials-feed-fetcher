//  Created by Ivan Fuertes on 6/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation
import FeedFetcher

protocol FeedImageView: class {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<Image, View: FeedImageView> where View.Image == Image  {
    private var task: FeedImageDataTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    weak var feedImageView: View?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImageData()  {
        feedImageView?.display(FeedImageViewModel(image: nil, location: model.location, description: model.description, isLoading: true, shouldRetry: false))
        task = imageLoader.loadImageData(from: model.url) {[weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            feedImageView?.display(FeedImageViewModel(image: image, location: model.location, description: model.description, isLoading: false, shouldRetry: false))
        } else {
            feedImageView?.display(FeedImageViewModel(image: nil, location: model.location, description: model.description, isLoading: false, shouldRetry: true))
        }                
    }
    
    func cancelLoadImageData() {
        task?.cancel()
    }
}
