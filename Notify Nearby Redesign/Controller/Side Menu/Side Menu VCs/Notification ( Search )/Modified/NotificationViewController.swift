//
//  NotificationViewController.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 10/10/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import SwiftyJSON
import SDWebImage
import FirebaseAuth

class NotificationViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate{

    var locationManager = CLLocationManager()
    
//    @IBOutlet weak var moreButton: UIBarButtonItem!
//    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var segmentedControls: UISegmentedControl!
    @IBAction func segmentedControlsPressed(_ sender: Any) {
        if segmentedControls.selectedSegmentIndex == 0 {
            arr.removeAll()
            notificationArr.removeAll()
            tableview.reloadData()
            you()
//            tableview
        }else if segmentedControls.selectedSegmentIndex == 1{
            arr.removeAll()
            notificationArr.removeAll()
            tableview.reloadData()
            following()
//            tableview.reloadData()
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    
    var arr = [Event]()
    var notificationArr = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
        you()
//        tableview.reloadData()
    }
    
    
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 275
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControls.selectedSegmentIndex == 0{
           return notificationArr.count
        }else{
            return arr.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentedControls.selectedSegmentIndex == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationTableViewCell
            cell.imageview!.sd_setImage(with: URL(string:notificationArr[indexPath.row].profileImage!), completed: nil)
           
            let username = notificationArr[indexPath.row].username
            let string = notificationArr[indexPath.row].string
            
            cell.des.text = "\(username!) \(string!)"
            return cell
        }
        else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationTableViewCell
        cell.imageview.sd_setImage(with: URL(string:arr[indexPath.row].event_image!), completed: nil)
        
        let title = arr[indexPath.row].event_title
        let interest = arr[indexPath.row].event_interests
        
        let array = stringToArray(string: interest!)
        let common =  commonInterest(firstSet: array, secondSet: MyInterestVC.interest)
        let common_interests = commonInterestToString(common: common)
        
        
        cell.des.text = "\(title!) has been posted near you for your interest \(common_interests)"
        return cell
        }
    }
    
    
    func you(){
        
        let uid = Auth.auth().currentUser?.uid
        let database = Database.database().reference().child("Notifications")
        print("Auth \(Auth.auth().currentUser?.uid)")
        
        database.child(uid!).observe(.value) { (snapshot) in
            //print(snapshot)
            self.notificationArr.removeAll()
            for snap in snapshot.children{
//                let json = JSON((snap as! DataSnapshot).value)
//                print(json["type"].stringValue)
                
                let notification = Notification(json: JSON((snap as! DataSnapshot).value))
//                notification.type
                print("Notification User ID: \(notification.userID)")
                let userReference =    Database.database().reference().child("Users").child(notification.userID!)
                
                userReference.observe(.value, with: { (snapshot) in
                    print(JSON(snapshot.value))
                    let userJSON = JSON(snapshot.value)
                    notification.username = userJSON["name"].stringValue
                    notification.profileImage = userJSON["profileImageUrl"].stringValue
//                    notification.storyname = us
                    self.notificationArr.append(notification)
                    self.tableview.reloadData()
                })
                
               
            }
            
            
//            self.tableview.reloadData()
        }
    }
    
    func following(){
        arr.removeAll()
        
        for event in HomeTVC.eventArray{
            
            guard let userLocation = self.locationManager.location else {return}
            let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
            
            let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
            let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
//            let user_searched_interest = stringToArray(string: MyInterestVC.interest)
            //FIXME: MODiFying
            
            if self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) <= 10000{
                var user_interests = MyInterestVC.interest
                var event_interests = self.stringToArray(string: event.event_interests!)
                var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                var common_interests_string = self.commonInterestToString(common: common_interests)
                
                // if there are any/some matching interest between user and event
                if !common_interests.isEmpty{
                    
//                    anno.title = common_interests_string
//                    anno.subtitle = event.event_title
//
//
//                    anno.event_title = event.event_title
//                    anno.event_interests  =  common_interests_string
//                    anno.event_image = event.event_image
//                    anno.event_noOfAccepted = event.event_noOfAccepted
//                    anno.event_noOfDenied = event.event_noOfDenied
//                    anno.event_noOfFavourite = event.event_noOfFavourite
//
                    //                            self.mapview.addAnnotation(anno)
                    arr.append(event)
                    
                }
                
                print(user_interests)
                print(event_interests)
                print ( "Common Interests\(self.commonInterest(firstSet: user_interests, secondSet: event_interests))" )
                print()
                tableview.reloadData()
                
            }
            
            
            
            
            
            
        }
    }
    
    
   
    
    
    //MARK: - GETTING common Interest
    
    //1: converting string to string array
    func stringToArray(string:String)->[String]{
        var string = string
        var removeWhiteSpcSTR = string.replacingOccurrences(of: " ", with: "")
        var strArray : [String] = removeWhiteSpcSTR.components(separatedBy: ",")
        return strArray
    }
    
    //2: finding common interest from two string arrays
    func commonInterest(firstSet:[String],secondSet:[String]) -> Set<String>{
        
        var userInterest = firstSet
        let userSet:Set = Set(userInterest.map { $0 })
        
        //    var str = "Hello, playground, sad, a,as "
        //    var removeWhiteSpcSTR = str.replacingOccurrences(of: " ", with: "")
        //    var strArray : [String] = removeWhiteSpcSTR.components(separatedBy: ",")
        
        let strSet:Set = Set(secondSet.map { $0 })
        //    print(strSet)
        
        let common = userSet.intersection(strSet)
        //        print(common)
        return common
    }
    
    //3: converting common set element to string form for printing
    func commonInterestToString(common : Set<String>) -> String {
        var stringers = ""
        for val in common {
            stringers = "\(stringers) \(val)"
        }
        return stringers
    }
    
    //TODO: To calculate the distance
    func calculateDistance(mainCoordinate: CLLocation,coordinate: CLLocation) -> Double{
        
        let distance = mainCoordinate.distance(from: coordinate)
        //        print("Calculate Distance: \(distance)")
        
        return distance
    }
}
