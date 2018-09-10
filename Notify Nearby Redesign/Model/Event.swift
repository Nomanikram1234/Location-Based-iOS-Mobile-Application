//
//  Event.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 09/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import Foundation
import MapKit

class Event:MKPointAnnotation{
    
    var uid:String?
   
    var event_title:String?
    var event_category:String?
    var event_interests:String?
    var event_key:String?
    var event_description:String?
    var event_image:String?
    var event_type:String?
    
    var event_noOfFavourite:String?
    var event_noOfAccepted:String?
    var event_noOfDenied:String?
    
    
    init(coordinate:CLLocationCoordinate2D) {
        super.init()
        self.coordinate = coordinate
    }

    
}
