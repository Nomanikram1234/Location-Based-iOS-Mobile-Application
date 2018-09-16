//
//  User.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 11/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import Foundation
import SwiftyJSON

class User{
    var name:String?
    var contact:String?
    var email:String?
    var profileImgURL : String?
    var userType: String?
    
    var followers: [String]?
    var following: [String]?
    var favourite: [String]?
    
   
    var events: [String]?
    
//    var interest = [String]()
    
    
    static var singleton = User()
    
    init(json:JSON) {
//        print(json["name"])
        name = json["name"].stringValue as! String
        email = json["email"].stringValue as! String
        userType = json["userType"].stringValue as! String
        contact = json["contact"].stringValue as! String
        profileImgURL = json["profileImageUrl"].stringValue
        
    }
    
     init(){
        
    }
}
