//  Created by Ivan Fuertes on 23/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import FeedFetcher
import FeedFetcheriOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let session = URLSession(configuration: .ephemeral)
        let httpClient = URLSessionHttpClient(session: session)
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let feedLoader = RemoteFeedLoader(from: url, httpClient: httpClient)
        let imageLoader = RemoteFeedImageLoader(httpClient: httpClient)
        
        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: imageLoader)
        
        window?.rootViewController = feedViewController
    }

}

