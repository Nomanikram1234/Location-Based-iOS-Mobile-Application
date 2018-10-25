//
//  JointInterest.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 01/10/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import Foundation
import SwiftyJSON

// Class JointInterest is Blueprint or Model for storing joint interests
class JointInterest{
    var id:String?
    var startTime:String?
    var endTime:String?
    var interest:String?
    
    init() {
        
    }

    // JSON Parsing
    init(json:JSON) {
        startTime = json["startTime"].stringValue
        endTime = json["endTime"].stringValue
        interest = json["interest"].stringValue
    }
    
    // JSON Parsing
    init(json:JSON,id: String?) {
        self.id = id
        startTime = json["startTime"].stringValue
        endTime = json["endTime"].stringValue
        interest = json["interest"].stringValue
    }
}
