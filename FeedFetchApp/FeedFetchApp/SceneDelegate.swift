//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import FeedFetcher
import FeedFetcheriOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
                                
        let (remoteFeedLoaderWithLocalFallback, localImageDataLoaderWithRemoteFallback) = composeFeedLoadersWithFallback()
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: remoteFeedLoaderWithLocalFallback,
            imageLoader: localImageDataLoaderWithRemoteFallback)
        
        window?.rootViewController = feedViewController                  
    }
                
}

private extension SceneDelegate {
                
    func composeFeedLoadersWithFallback() -> (feed: FeedLoaderWithFallbackComposite, image: FeedImageDataLoaderWithFallbackComposite) {
        let (remoteFeedLoader, remoteImageDataLoader) = makeRemoteFeedLoader()
        let (localFeedLoader, localImageDataLoader) = makeLocalFeedLoader()
        
        let remoteFeedLoaderWithCache = FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
        let remoteFeedImageDataLoaderWithCache = FeedImageDataLoaderCacheDecorator(decoratee: remoteImageDataLoader, cache: localImageDataLoader)
        
        let feedComposite = FeedLoaderWithFallbackComposite(primaryFeedLoader: remoteFeedLoaderWithCache, fallbackFeedLoader: localFeedLoader)
        let imageComposite = FeedImageDataLoaderWithFallbackComposite(primaryLoader: localImageDataLoader, fallbackLoader: remoteFeedImageDataLoaderWithCache)
        
        return (feedComposite, imageComposite)
    }
    
    func makeLocalFeedLoader() -> (feed: LocalFeedLoader, image: LocalFeedImageDataLoader) {
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        let feedStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        
        let localFeedLoader = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        let localImageDataLoader = LocalFeedImageDataLoader(store: feedStore)
        
        return (localFeedLoader, localImageDataLoader)
    }
            
    func makeRemoteFeedLoader() -> (feed: RemoteFeedLoader, image: RemoteFeedImageLoader) {
        let httpClient = makeRemoteClient()
        
        let remoteFeedLoader = RemoteFeedLoader(from: remoteFeedLoaderURL, httpClient: httpClient)
        let remoteImageDataLoader = RemoteFeedImageLoader(httpClient: httpClient)
        
        return (remoteFeedLoader, remoteImageDataLoader)
    }
    
    func makeRemoteClient() -> HttpClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwayOfflineHttpClient()
        default:
            let session = URLSession(configuration: .ephemeral)
            let httpClient = URLSessionHttpClient(session: session)
            
            return httpClient
        }
    }
    
    var remoteFeedLoaderURL: URL {
        URL(string:
            "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
    }
    
}

class AlwayOfflineHttpClient: HttpClient {
    private class Task: HttpClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(.failure(NSError(domain: "offline", code: 0, userInfo: nil)))
        
        return Task()
    }
}

