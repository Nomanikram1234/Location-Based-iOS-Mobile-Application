//
//  NotificationTableViewCell.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 10/10/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
   
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var des: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
