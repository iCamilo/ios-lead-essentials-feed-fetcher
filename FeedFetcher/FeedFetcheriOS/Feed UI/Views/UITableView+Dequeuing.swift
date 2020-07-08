//  Created by Ivan Fuertes on 8/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
