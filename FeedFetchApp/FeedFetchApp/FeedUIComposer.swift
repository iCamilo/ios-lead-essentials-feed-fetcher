import UIKit
import FeedFetcher
import FeedFetcheriOS

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> FeedLoader.Publisher,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let feedController = make(delegate: presentationAdapter, title: FeedPresenter.title)
        let feedPresenter = FeedPresenter( feedView: FeedViewAdapter(controller: feedController,
                                                                     imageLoader: imageLoader),
                                           loadingView: WeakRefVirtualProxy(feedController),
                                           errorView: WeakRefVirtualProxy(feedController))
                                   
        presentationAdapter.presenter = feedPresenter
        
        return feedController
    }
    
    private static func make(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        
        return feedController
    }
}
    

