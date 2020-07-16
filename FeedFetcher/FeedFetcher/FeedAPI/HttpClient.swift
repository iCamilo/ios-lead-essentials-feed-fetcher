//  Created by Ivan Fuertes on 30/05/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import Foundation

public protocol HttpClient {
    typealias Result = Swift.Result<(response: HTTPURLResponse, data: Data), Error>    
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
