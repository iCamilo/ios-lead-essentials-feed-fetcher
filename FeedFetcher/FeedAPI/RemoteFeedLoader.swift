//  Created by Ivan Fuertes on 28/05/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public final class RemoteFeedLoader: FeedLoader {    
    private let client: HttpClient
    private let url: URL
    
    public enum Error: Swift.Error {        
        public typealias RawValue = String
        
        case connectivity
        case invalidData
    }
    
    public init(from url: URL, httpClient client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success((let response, let data)):
                let result = self.map(response: response, data: data)
                
                completion(result)
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(response: HTTPURLResponse, data: Data) -> LoadFeedResult {
        do {
            let remoteItems = try FeedItemsMapper.map(data: data, from: response)
            
            return .success(remoteItems.mapToItems())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func mapToItems() -> [FeedImage] {
        return self.map {
            FeedImage(id: $0.id,
                     url: $0.image,
                     description: $0.description,
                     location: $0.location)
        }
    }
}
