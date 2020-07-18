//  Created by Ivan Fuertes on 29/06/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit
import FeedFetcher

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
    @IBOutlet public private(set) var errorView: ErrorView!
    
    var delegate: FeedViewControllerDelegate?
    
    var tableModel = [FeedImageCellController]() {
        didSet { self.tableView.reloadData() }
    }
            
    public override func viewDidLoad() {
        super.viewDidLoad()
                        
        refresh()
    }
        
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ viewModel: FeedLoadingViewModel) {                
        if viewModel.isLoading {
            self.refreshControl?.beginRefreshing()
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: FeedErrorViewModel) {
        if let errorMessage = viewModel.message {
            errorView.show(message: errorMessage)
        } else {
            errorView.hideMessage()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelCellControllerLoad(forRowAt: indexPath)
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
