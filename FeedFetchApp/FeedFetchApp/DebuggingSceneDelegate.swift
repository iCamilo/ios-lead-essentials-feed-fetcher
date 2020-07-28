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
        guard let connectivity = UserDefaults.standard.string(forKey: "connectivity") else {
            return super.makeRemoteClient()
        }
        
        switch  connectivity {
        case "offline":
            return OfflineHttpClient()
        default:
            return OnlineHttpClient()
        }
    }
    
    private func resetLocalCacheIfRequired(storeURL url: URL) {
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
}

private final class OfflineHttpClient: HttpClient {
    private class Task: HttpClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(.failure(NSError(domain: "offline", code: 0, userInfo: nil)))
        
        return Task()
    }
}

private final class OnlineHttpClient: HttpClient {
    private class Task: HttpClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        let (data, response) = makeSuccessfulResponse(for: url)
        completion(.success((response, data)))
        
        return Task()
    }
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()

        default:
            return makeFeedData()
        }
    }

    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
    
}
#endif
