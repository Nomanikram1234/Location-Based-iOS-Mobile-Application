//
//  StoriesCVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 04/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class StoriesCVC: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 7
        layer.masksToBounds = true
    }
}
