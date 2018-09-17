//
//  ProfileTVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 04/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON
import CoreLocation

class ProfileTVC: UITableViewController ,UICollectionViewDelegate,UICollectionViewDataSource , UINavigationControllerDelegate , UIImagePickerControllerDelegate{
    
     var myStories = [Event]()
    var myInterestBasedStories = [Event]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == storyCollectionview{
            return (myStories.count)
        }
        else if collectionView == interestCollectionview{
            return myInterestBasedStories.count
        }
        else{
            return 15
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == storyCollectionview{
            let cell = storyCollectionview.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoriesCVC
            cell.imageview.sd_setImage(with: URL(string: (myStories[indexPath.row].event_image)!), completed: nil )
            cell.title.text = myStories[indexPath.row].event_title
            return cell
            
        }
        else if collectionView == interestCollectionview{
            let cell = interestCollectionview.dequeueReusableCell(withReuseIdentifier: "interestCell", for: indexPath) as! InterestCVC
            print(myInterestBasedStories[indexPath.row].event_title)
            cell.title.text = myInterestBasedStories[indexPath.row].event_title
            cell.imageview.sd_setImage(with: URL(string: myInterestBasedStories[indexPath.row].event_image!), completed: nil)
            return cell
        }
        else if collectionView == followerCollectionview{
            let cell = followerCollectionview.dequeueReusableCell(withReuseIdentifier: "followerCell", for: indexPath) as! FollowersCVC
          cell.imageview.image = UIImage(named: "avatar")
            return cell
        }else{
            return UICollectionViewCell()
        }
        
        
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var noOfInterests: UILabel!
    @IBOutlet weak var noOfStories: UILabel!
    @IBOutlet weak var profileBG_imageview: UIImageView!
    @IBOutlet weak var profile_imageview: RoundedImage!
    
    @IBOutlet weak var storyCollectionview: UICollectionView!
    @IBOutlet weak var interestCollectionview: UICollectionView!
    @IBOutlet weak var followerCollectionview: UICollectionView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    var locationManager = CLLocationManager()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        name.text =  User.singleton.name
//        profile_imageview.sd_setImage(with: URL(string:User.singleton.profileImgURL!), completed: nil)
        
        noOfInterests.text = "\(MyInterestVC.interest.count)"
        
        if let image = User.singleton.profileImgURL{
            profile_imageview.sd_setImage(with: URL(string: image), completed: nil)
            profileBG_imageview.sd_setImage(with: URL(string: image), completed: nil)
            
           
        }
        
        
         mystories()
     myInterestStories()
        noOfInterests.text = "\(MyInterestVC.interest.count)"
        
        sidemenu()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
//            revealViewController().rightViewRevealWidth = 160
            
            
        }
    }
    
    func mystories(){
        let database = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        var count = 0
        
        for event in HomeTVC.eventArray{
            if event.event_author_uid == uid{
                myStories.append(event)
                count = count + 1
                storyCollectionview.reloadData()
            }
        }
            noOfStories.text = "\(count)"
       
    }
    
    func myInterestStories(){
        for event in HomeTVC.eventArray{
            
            guard let userLocation = self.locationManager.location else {return}
            let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
            
            let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
            let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
            
            //FIXME: MODiFying
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
                        anno.event_image = event.event_image
                        anno.event_noOfAccepted = event.event_noOfAccepted
                        anno.event_noOfDenied = event.event_noOfDenied
                        anno.event_noOfFavourite = event.event_noOfFavourite
                        
                        myInterestBasedStories.append(anno)
                        interestCollectionview.reloadData()
                    }
                    
                    print(user_interests)
                    print(event_interests)
                    print ( "Common Interests\(self.commonInterest(firstSet: user_interests, secondSet: event_interests))" )
                    print()
                    
                }
                
            
            
        }
    }
    
    
    //TODO: To calculate the distance
    func calculateDistance(mainCoordinate: CLLocation,coordinate: CLLocation) -> Double{
        
        let distance = mainCoordinate.distance(from: coordinate)
        //        print("Calculate Distance: \(distance)")
        
        return distance
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 1
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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

}
