//  Created by Ivan Fuertes on 27/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

#if DEBUG
import UIKit
import FeedFetcher

class DebuggingSceneDelegate: SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        resetLocalCacheIfRequired(storeURL: localStoreURL)
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HttpClient {
        guard UserDefaults.standard.string(forKey: "connectivity") == "offline" else {
            return super.makeRemoteClient()
        }
        
        return AlwayOfflineHttpClient()
    }
    
    private func resetLocalCacheIfRequired(storeURL url: URL) {
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
}

private final class AlwayOfflineHttpClient: HttpClient {
    private class Task: HttpClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(.failure(NSError(domain: "offline", code: 0, userInfo: nil)))
        
        return Task()
    }
}
#endif
