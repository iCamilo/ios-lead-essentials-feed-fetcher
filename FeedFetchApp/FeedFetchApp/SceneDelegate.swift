//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import FeedFetcher
import FeedFetcheriOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    var localStoreURL : URL {
        NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
    }
    
    private lazy var httpClient: HttpClient = {
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHttpClient(session: session)
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    convenience init(httpClient: HttpClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let (remoteFeedLoaderWithLocalFallback, localImageDataLoaderWithRemoteFallback) = composeFeedLoadersWithFallback()
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: remoteFeedLoaderWithLocalFallback,
            imageLoader: localImageDataLoaderWithRemoteFallback)
        let navigationController = UINavigationController(rootViewController: feedViewController)
        
        window?.rootViewController = navigationController
    }
            
    func makeRemoteClient() -> HttpClient {
        return self.httpClient
    }
                                
    private func composeFeedLoadersWithFallback() -> (feed: FeedLoaderWithFallbackComposite, image: FeedImageDataLoaderWithFallbackComposite) {
        let (remoteFeedLoader, remoteImageDataLoader) = makeRemoteFeedLoader()
        let (localFeedLoader, localImageDataLoader) = makeLocalFeedLoader()
        
        let remoteFeedLoaderWithCache = FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
        let remoteFeedImageDataLoaderWithCache = FeedImageDataLoaderCacheDecorator(decoratee: remoteImageDataLoader, cache: localImageDataLoader)
        
        let feedComposite = FeedLoaderWithFallbackComposite(primaryFeedLoader: remoteFeedLoaderWithCache, fallbackFeedLoader: localFeedLoader)
        let imageComposite = FeedImageDataLoaderWithFallbackComposite(primaryLoader: localImageDataLoader, fallbackLoader: remoteFeedImageDataLoaderWithCache)
        
        return (feedComposite, imageComposite)
    }
    
    private func makeLocalFeedLoader() -> (feed: LocalFeedLoader, image: LocalFeedImageDataLoader) {
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageDataLoader = LocalFeedImageDataLoader(store: store)
        
        return (localFeedLoader, localImageDataLoader)
    }
            
    private func makeRemoteFeedLoader() -> (feed: RemoteFeedLoader, image: RemoteFeedImageLoader) {
        let httpClient = makeRemoteClient()
        
        let remoteFeedLoader = RemoteFeedLoader(from: remoteFeedLoaderURL, httpClient: httpClient)
        let remoteImageDataLoader = RemoteFeedImageLoader(httpClient: httpClient)
        
        return (remoteFeedLoader, remoteImageDataLoader)
    }
    
    private var remoteFeedLoaderURL: URL {
        URL(string:
            "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
    }
    
}
