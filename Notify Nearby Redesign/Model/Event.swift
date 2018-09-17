//
//  Event.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 09/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON


// This class is for both ads and stories(Around/Interest Based)
class Event:MKPointAnnotation{
    
    var uid:String?
   
    var event_title:String?
    var event_category:String?
    var event_interests:String?
    var event_key:String?
    var event_description:String?
    var event_image:String?
    var event_type:String?
    var event_author:String?
    var event_author_uid:String?
    
    var event_latitude:Double?
    var event_longitude:Double?
    
    var event_noOfFavourite:String?
    var event_noOfAccepted:String?
    var event_noOfDenied:String?
    
    var event_Favourite:[String]?
    var event_Accepted:[String]?
    var event_Denied:[String]?
    
//    static var singleton = Event()
    
    init(coordinate:CLLocationCoordinate2D) {
        super.init()
        self.coordinate = coordinate
    }

   init(json:JSON) {
    event_title = json["title"].stringValue
    event_description = json["description"].stringValue
    event_type = json["type"].stringValue
    event_image = json["image"].stringValue
    event_latitude = json["lat"].doubleValue
    event_longitude = json["longitude"].doubleValue
    event_interests = json["interest"].stringValue
    event_author = json["storypostedby"].stringValue
    event_image = json["image"].stringValue
    event_noOfFavourite = json["favouriteNumber"].stringValue
    event_noOfDenied = json["deniedNumber"].stringValue
    event_noOfAccepted = json["acceptedNumber"].stringValue
    event_author_uid = json["uid"].stringValue
    }
    
    init(eventId:String , json:JSON) {
        event_title = json["title"].stringValue
        event_description = json["description"].stringValue
        event_type = json["type"].stringValue
        event_image = json["image"].stringValue
        event_latitude = json["lat"].doubleValue
        event_longitude = json["longitude"].doubleValue
        event_interests = json["interest"].stringValue
        event_author = json["storypostedby"].stringValue
        event_image = json["image"].stringValue
        event_noOfFavourite = json["favouriteNumber"].stringValue
        event_noOfDenied = json["deniedNumber"].stringValue
        event_noOfAccepted = json["acceptedNumber"].stringValue
        event_author_uid = json["uid"].stringValue
        event_key = eventId
//        print("Description:\(event_description)")
//
//        print("Event ID: \(event_key)")
//        print("Event Image: \(event_image)")
    }
    
    override init() {
        
    }
}
