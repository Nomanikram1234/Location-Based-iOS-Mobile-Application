//
//  ActivityRightSideMenuVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 09/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftyJSON
import SDWebImage
import CoreLocation


class ActivityRightSideMenuVC: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource ,CLLocationManagerDelegate{
    
    @IBOutlet weak var segmentedcontrols: UISegmentedControl!
    
    @IBOutlet weak var searchField: UITextField!
    
    var locationManager = CLLocationManager()
    
    var searchEvents = [Event]()
    
    var selectedIndex:Int?

    @IBOutlet weak var tableview: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************ActivityRightSideMenuVC**************")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityRightSideMenuTableViewCell
        cell.title.text = searchEvents[indexPath.row].event_title
        cell.type.text = searchEvents[indexPath.row].event_type
        cell.interests.text = searchEvents[indexPath.row].event_interests
        cell.imageview.sd_setImage(with: URL(string: searchEvents[indexPath.row].event_image!), completed: nil)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        print(selectedIndex)
        performSegue(withIdentifier: "search", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? StoriesDetailVC{
            detailVC.Previouskey = searchEvents[selectedIndex!].event_key
        }
    }
    
    @IBAction func segmentedControlsChanged(_ sender: Any) {
        
        // Interest Based
        if segmentedcontrols.selectedSegmentIndex == 0 {
            print("Interest Based Search Selected")
        }
        // Location Based
        if segmentedcontrols.selectedSegmentIndex == 1{
            print("Location Based Search Selected")
        }
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        
        searchEvents.removeAll()
        
            print("Pressed 0")
        
        var latitude: Any?
        var longitude: Any?
        
        
//        if segmentedcontrols.selectedSegmentIndex == 1{
//
//        }
        
        
        //Mark: Fetching events from array and searching from those array if segmented control index is at 0
        if segmentedcontrols.selectedSegmentIndex == 0 {
            
            for event in HomeTVC.eventArray{
                
                guard let userLocation = self.locationManager.location else {return}
                let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
                
                let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
                let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
                let user_searched_interest = stringToArray(string: (searchField.text?.lowercased())!) // searchField.text?.lowercased() is the term(interest) we search for
                //FIXME: MODiFying
               
                    if self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) <= 10000{
                        var user_interests = user_searched_interest
                        var event_interests = self.stringToArray(string: event.event_interests!)
                        var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                        var common_interests_string = self.commonInterestToString(common: common_interests)
                        
                        // if there are any/some matching interest between user and event
                        if !common_interests.isEmpty{
                            
                            anno.title = common_interests_string
                            anno.subtitle = event.event_title
                            
                            
                            anno.event_title = event.event_title
                            anno.event_interests  =  common_interests_string
                            anno.event_image = event.event_image
                            anno.event_noOfAccepted = event.event_noOfAccepted
                            anno.event_noOfDenied = event.event_noOfDenied
                            anno.event_noOfFavourite = event.event_noOfFavourite
                            
//                            self.mapview.addAnnotation(anno)
                            searchEvents.append(event)
                            
                        }
                        
                        print(user_interests)
                        print(event_interests)
                        print ( "Common Interests\(self.commonInterest(firstSet: user_interests, secondSet: event_interests))" )
                        print()
                        tableview.reloadData()
                        
                    }
                
                
                
              
               
                
            }
    }
        
        
        // segmented control index is at 1
        if segmentedcontrols.selectedSegmentIndex == 1 {
            print("Pressed 1")
            
            
            /* Geocoding Enabled */
            var geocoder = CLGeocoder()
            print(self.searchField.text?.lowercased())
            geocoder.geocodeAddressString((self.searchField.text?.lowercased())!) {
                placemarks, error in
                let placemark = placemarks?.first
                let lat = placemark?.location?.coordinate.latitude
                let lon = placemark?.location?.coordinate.longitude
                
                
                // if we have some values for latitude and longitude then we will find the events around that coordinate(using latitude and longitude value)
                if lat != nil , lon != nil{
                    print("Lat: \(lat!), Lon: \(lon!)")
                    
                    latitude = lat!
                    longitude = lon!
                    ///////////////////////
                    
                    
                    // search for event
                    for event in HomeTVC.eventArray{
                        
                        //                guard let userLocation = self.locationManager.location else {return}
                        let addressLocation = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                        let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
                        
                        let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
                        let distanceDifference = self.calculateDistance(mainCoordinate: addressLocation , coordinate: coordinate)
                        
                        
                        
                        let address_coordinate = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude! as! CLLocationDegrees)
                        
                        if self.calculateDistance(mainCoordinate: address_coordinate , coordinate: coordinate) <= 10000
                        {
                            var user_interests = MyInterestVC.interest
                            var event_interests = self.stringToArray(string: event.event_interests!)
                            var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                            var common_interests_string = self.commonInterestToString(common: common_interests)
                            
                            print("Pin inside 10km radius , Distance Difference: \(Int(distanceDifference))")
//
//                            anno.title = event.event_title
//                            anno.subtitle = event.event_interests
                            
                            
                            
//                            anno.event_title = event.event_title
//                            anno.event_interests  =  common_interests_string
//                            anno.event_key = event.event_key
//                            anno.event_image = event.event_image
//                            anno.event_noOfAccepted = event.event_noOfAccepted
//                            anno.event_noOfDenied = event.event_noOfDenied
//                            anno.event_noOfFavourite = event.event_noOfFavourite
                            
                            //                        if event.event_type == "advertisement"{
                            //                            HomeTVC.adsArray.append(event)
                            //                        }
                            //
                            //                    self.localNotification(title: event.event_title, subtitle: event.event_title, body: common_interests_string, lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
                            //                        self.mapview.addAnnotation(anno)
                            self.searchEvents.append(event)
                            
                        }
//                        self.tableview.reloadData()
                        
                        
                    }
                    
                    
                    self.tableview.reloadData()
                    
                    ///////////////////////
                    print("LA: \(latitude!)")
                    print("LO: \(longitude!)")
                }// Incase we donot get any value for latitude and longitude then we set the corresponding value equal to user's latitude and longitude in order to avoid errors
                else{
                    print("Error")
                    
                    guard let userLocation = self.locationManager.location else {return}
                    User.singleton.address_latitude = userLocation.coordinate.latitude
                    User.singleton.address_longitude = userLocation.coordinate.longitude
                    
                }
                
            }
            /* Geocoding Disabled */
            
            
//            for event in HomeTVC.eventArray{
//
////                guard let userLocation = self.locationManager.location else {return}
//                let addressLocation = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
//                let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
//
//                let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
//                let distanceDifference = self.calculateDistance(mainCoordinate: addressLocation , coordinate: coordinate)
//
//
//
//                let address_coordinate = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude! as! CLLocationDegrees)
//
//                    if self.calculateDistance(mainCoordinate: address_coordinate , coordinate: coordinate) <= 10000
//                    {
//                        var user_interests = MyInterestVC.interest
//                        var event_interests = self.stringToArray(string: event.event_interests!)
//                        var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
//                        var common_interests_string = self.commonInterestToString(common: common_interests)
//
//                        print("Pin inside 10km radius , Distance Difference: \(Int(distanceDifference))")
//
//                        anno.title = event.event_title
//                        anno.subtitle = event.event_interests
//
//
//
//                        anno.event_title = event.event_title
//                        anno.event_interests  =  common_interests_string
//                        anno.event_key = event.event_key
//                        anno.event_image = event.event_image
//                        anno.event_noOfAccepted = event.event_noOfAccepted
//                        anno.event_noOfDenied = event.event_noOfDenied
//                        anno.event_noOfFavourite = event.event_noOfFavourite
//
////                        if event.event_type == "advertisement"{
////                            HomeTVC.adsArray.append(event)
////                        }
//                        //
//                        //                    self.localNotification(title: event.event_title, subtitle: event.event_title, body: common_interests_string, lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
////                        self.mapview.addAnnotation(anno)
//                        searchEvents.append(event)
//                    }
//
//
//
//            }
        }
//        searchField.text = ""
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
    
    
    // when we touch outside the textfield then keyboard will disappear
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // when we will touch on return button on key it will hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
}
