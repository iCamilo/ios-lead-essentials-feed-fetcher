//  Created by Ivan Fuertes on 27/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    
    private var feed = [FeedImageViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = feed[indexPath.row]
        let feedImageCell = tableView.dequeueReusableCell(withIdentifier: FeedImageCell.reuseIdentifier) as! FeedImageCell
        feedImageCell.configure(with: viewModel)
        
        return feedImageCell
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.feed.isEmpty {
                self.feed = FeedImageViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
}
