//
//  TopInterestCollectionViewCell.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 07/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class TopInterestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 7
        name.layer.masksToBounds = true
//        layer.masksToBounds = true
    }
    
}
