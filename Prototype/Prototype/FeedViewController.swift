//  Created by Ivan Fuertes on 27/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    
    private var feedImagesViewModels = FeedImageViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  feedImagesViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = feedImagesViewModels[indexPath.row]
        let feedImageCell = tableView.dequeueReusableCell(withIdentifier: FeedImageCell.reuseIdentifier) as! FeedImageCell
        feedImageCell.configure(with: viewModel)
        
        return feedImageCell
    }
    
}
