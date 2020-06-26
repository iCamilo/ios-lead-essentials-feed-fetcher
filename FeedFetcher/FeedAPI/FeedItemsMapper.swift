//  Created by Ivan Fuertes on 30/05/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

final class FeedItemsMapper {
    struct Items: Codable {
        var items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { return 200 }
        
    static func map(data: Data, from response: HTTPURLResponse) throws ->  [RemoteFeedItem] {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Items.self, from: data) else {
           throw RemoteFeedLoader.Error.invalidData
        }
                                    
        return root.items
    }
}
