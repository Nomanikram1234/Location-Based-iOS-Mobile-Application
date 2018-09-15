//
//  EventCalloutView.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 09/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class EventCalloutView: UIView {
    
    @IBOutlet weak var event_title: UILabel!
     // variable created to use one variable for mentioning interest/ads
    @IBOutlet weak var event_basedon: UILabel!
    @IBOutlet weak var event_noOfAccepts: UILabel!
    @IBOutlet weak var event_noOfDenied: UILabel!
    @IBOutlet weak var event_noOfFavourite: UILabel!
    
    @IBOutlet weak var event_imageview: RoundedImage!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var readMoreButton: BlackBorderSmallButton!
    
}
