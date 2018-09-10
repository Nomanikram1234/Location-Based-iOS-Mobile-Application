//
//  interestStoryDetailCVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 09/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class interestStoryDetailCVC: UICollectionViewCell {
    
    @IBOutlet weak var interest: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 7
    }
}
