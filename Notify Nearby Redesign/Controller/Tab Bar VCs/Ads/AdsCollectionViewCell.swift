//
//  AdsCollectionViewCell.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 06/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class AdsCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 7
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
    
}
