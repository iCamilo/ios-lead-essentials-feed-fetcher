//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import Combine
import FeedFetcher
import FeedFetcheriOS
import CoreData
import FeedFetcherAPI
import FeedFetcherCache

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
            
    private lazy var httpClient: HttpClient = {
        let session = URLSession(configuration: .ephemeral)
        
        return URLSessionHttpClient(session: session)
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        
        return try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HttpClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    func configureWindow() {
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalFeedImageDataLoaderWithRemoteFallback)
        let navigationController = UINavigationController(rootViewController: feedViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
                                                    
    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        let remoteFeedLoader = RemoteFeedLoader(from: remoteFeedLoaderURL, httpClient: httpClient)
        
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalFeedImageDataLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageDataLoader = LocalFeedImageDataLoader(store: store)
        let remoteImageDataLoader = RemoteFeedImageLoader(httpClient: httpClient)
        
        return localImageDataLoader
            .loadPublisher(from: url)
            .fallback(to: {
                remoteImageDataLoader
                    .loadPublisher(from: url)
                    .caching(to: localImageDataLoader, using: url)
            })
    }
         
    private var remoteFeedLoaderURL: URL {
        URL(string:
            "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
    }
    
}
