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
    @IBOutlet weak var eventAddress: UITextView!
    @IBOutlet weak var eventDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 14
        imageview.layer.cornerRadius = 7
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        
        
    }
}
