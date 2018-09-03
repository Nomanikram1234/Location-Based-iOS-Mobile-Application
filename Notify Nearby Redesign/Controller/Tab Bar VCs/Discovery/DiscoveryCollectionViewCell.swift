//
//  DiscoveryCollectionViewCell.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class DiscoveryCollectionViewCell: UICollectionViewCell {
 
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 14
        imageview.layer.cornerRadius = 14
        
    }
}
