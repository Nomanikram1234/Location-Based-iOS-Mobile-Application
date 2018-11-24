//
//  CategoryListViewController.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 24/11/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
class CategoryListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var locationManager = CLLocationManager()
    var searchEvents = [Event]()
    
    var selectedIndex:Int?
    
    @IBOutlet weak var navbar: UINavigationBar!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let StoriesDetailVC = segue.destination as? StoriesDetailVC{
            
            StoriesDetailVC.Previouskey = searchEvents[selectedIndex!].event_key
        }
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showCategoryItemDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryListTableViewCell
        cell?.title.text = searchEvents[indexPath.row].event_title
        cell?.imageview!.sd_setImage(with: URL(string: searchEvents[indexPath.row].event_image!), completed: nil)
        
        return cell!
    }
    

    @IBOutlet weak var tableview: UITableView!
    

    
    var search = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.topItem?.title = search
        searchCategory()
        // Do any additional setup after loading the view.
//        search()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func searchCategory()  {
        
        for event in HomeTVC.eventArray{
            
            guard let userLocation = self.locationManager.location else {return}
            let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
            
            let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
            let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
            let user_searched_interest = stringToArray(string: (search.lowercased())) // searchField.text?.lowercased() is the term(interest) we search for
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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

    func calculateDistance(mainCoordinate: CLLocation,coordinate: CLLocation) -> Double{
        
        let distance = mainCoordinate.distance(from: coordinate)
        //        print("Calculate Distance: \(distance)")
        
        return distance
    }
}


