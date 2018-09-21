//
//  InterestVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseDatabase
import SwiftyJSON

class InterestVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, MKMapViewDelegate,CLLocationManagerDelegate{
 
   
    // static array to populate collection view at the top
    let arr = ["sport","gaming","news","traffic","education"]
    var interestArray = [Event]()
    var selectedInterestIndex: Int?

    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    @IBOutlet weak var interest_collectionview: UICollectionView!
    
    @IBOutlet weak var commonInterest_collectionview: UICollectionView!
    
    let database = Database.database().reference()
    
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove all elements from array to avoid over population / duplication
        HomeTVC.eventArray.removeAll()
        HomeTVC.fetchEvents() //FIXME: MADE CHANGES ON FRIDAY
        
        // counter number of events
        print("Counter: \(HomeTVC.eventArray.count)")
        
        database.child("stories").observe(DataEventType.value) { (snapshot) in
            
            for key in snapshot.children{
                let json = JSON((key as! DataSnapshot).value)
                let id = JSON((key as! DataSnapshot).key).stringValue
                let event = Event(eventId:id , json: json)
                
                // getting user location
                guard let userLocation = self.locationManager.location else {return}
                // getting lat and long for event locations
                let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
                
                // anno short for annotation(Map Pin)
                let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
                let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
                
                
                // if INTEREST is selected in segmented controls
//                if self.segmentedcontrols.selectedSegmentIndex == 0{
                
                    if self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) <= 10000{
                        var user_interests = MyInterestVC.interest
                        var event_interests = self.stringToArray(string: event.event_interests!)
                        var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                        var common_interests_string = self.commonInterestToString(common: common_interests)
                        
                        // if there are any/some matching interest between user and event
                        if !common_interests.isEmpty{
                            anno.title = common_interests_string
                            anno.subtitle = event.event_title
                            
                            anno.event_title = event.event_title
                            anno.event_interests  =  common_interests_string
                            
                            anno.event_key = event.event_key
                            anno.event_image = event.event_image
//                        self.interest_collectionview.reloadData()
                           self.interestArray.append(anno)
                            self.interest_collectionview.reloadData()
                        }
                        
                        print(user_interests)
                        print(event_interests)
                        print ( "Common Interests\(self.commonInterest(firstSet: user_interests, secondSet: event_interests))")
                        print()
                        
                    }
                
//                }
                
                
//                HomeTVC.eventArray.append(event)
            }
            print("fetchEventsAndDisplayOnMap(): fetched Events")
            print("Event Array: Number of Events -> \(HomeTVC.eventArray.count)")
        }
        
//        for event in HomeTVC.eventArray{
//
//            guard let userLocation = self.locationManager.location else {return}
//            let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
//
//            let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
//            let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
//
//
//                if self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) <= 10000{
//                    var user_interests = MyInterestVC.interest
//                    var event_interests = self.stringToArray(string: event.event_interests!)
//                    var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
//                    var common_interests_string = self.commonInterestToString(common: common_interests)
//
//                    // if there are any/some matching interest between user and event
//                    if !common_interests.isEmpty{
////                        print("Common Interest Index Path: \(interestArray.in)")
//                        anno.title = common_interests_string
//                        anno.subtitle = event.event_title
//
//
//                        anno.event_title = event.event_title
//                        anno.event_interests  =  common_interests_string
//                        anno.event_image = event.event_image
//
//                        if !interestArray.contains(anno){
//                        interestArray.append(anno)
//                            interest_collectionview.reloadData()
//                        }else{
//                            continue
//                        }
//
////                        self.mapview.addAnnotation(anno)
//                    }
//
////                    print(user_interests)
////                    print(event_interests)
////                    print ( "Common Interests\(self.commonInterest(firstSet: user_interests, secondSet: event_interests))" )
////                    print()
//
//                    print(interestArray)
//
//                }
//
//
//
//
//        }
        
        
        // Do any additional setup after loading the view.
        sidemenu()
        commonInterest_collectionview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // enables the functionality of navigation bar buttons
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 275
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == interest_collectionview{
        
        return interestArray.count
        }else {
            return arr.count
        }
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == interest_collectionview{
            
        
            
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InterestCollectionViewCell
            cell.imageview.sd_setImage(with: URL(string: interestArray[indexPath.row].event_image!), completed: nil)
        cell.title.text = interestArray[indexPath.row].event_title
        return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "interest_cell", for: indexPath) as! TopInterestCollectionViewCell
            
            cell.name.text = arr[indexPath.row]
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == interest_collectionview{
        return CGSize(width: interest_collectionview.frame.width - 150, height: interest_collectionview.frame.height - 130)
        }else{
            return CGSize(width: commonInterest_collectionview.frame.size.width / 4, height: commonInterest_collectionview.frame.size.height - 8)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedInterestIndex = indexPath.row
        print("Selected Index: \(indexPath.row)")
        performSegue(withIdentifier: "showInterestBasedEventDetails", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let StoriesDetailVC = segue.destination as? StoriesDetailVC{
            print(interestArray[selectedInterestIndex!].event_key)
            StoriesDetailVC.Previouskey = interestArray[selectedInterestIndex!].event_key
            
            
        }
    }
    
    
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
