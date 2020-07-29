//  Created by Ivan Fuertes on 29/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
