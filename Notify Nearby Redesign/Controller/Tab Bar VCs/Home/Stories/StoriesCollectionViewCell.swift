//
//  StoriesCollectionViewCell.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 06/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class StoriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = layer.frame.height / 2
        layer.masksToBounds = true
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
   

}
