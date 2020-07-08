//  Created by Ivan Fuertes on 8/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
