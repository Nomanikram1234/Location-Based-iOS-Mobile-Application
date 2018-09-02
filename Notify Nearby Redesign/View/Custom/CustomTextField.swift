//
//  CustomTextField.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 02/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 7
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.lightGray.cgColor
        
    }
}
