//  Created by Ivan Fuertes on 14/07/20.
//  Copyright © 2020 Ivan Fuertes. All rights reserved.

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var container: UIView!
    @IBOutlet public private(set) var label: UIButton!
    
    public var message: String? {
        get { return isVisible ? label.text : nil }
    }
    
    private var isVisible: Bool {
        return alpha > 0
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        addRounderBorderColor()
        label.text = nil
        alpha = 0
    }
    
    func show(message: String) {
        self.label.text = message
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @IBAction func hideMessage() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.label.text = nil }
        })
    }
    
    private func addRounderBorderColor() {
        container.layer.cornerRadius = 5
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.cayenne.cgColor
    }
}

private extension UIButton {
    var text: String? {
        get { titleLabel?.text }
        set { setTitle(newValue, for: .normal) }
    }
}

private extension UIColor {
    static var cayenne: UIColor {
        UIColor(red: 148/255, green: 17/255, blue: 0, alpha: 1.0)
    }
}

