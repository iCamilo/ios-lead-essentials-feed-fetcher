//  Created by Ivan Fuertes on 2/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    private let feedViewModel: FeedViewModel
            
    init(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
    }

    @objc func refresh() {
        feedViewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        feedViewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
}
