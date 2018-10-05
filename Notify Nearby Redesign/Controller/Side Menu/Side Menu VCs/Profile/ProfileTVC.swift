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
    
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    var myStories = [Event]()
    var selectedStoryIndex:Int?
    
    var myInterestBasedStories = [Event]()
    var selectedInterestBasedIndex:Int?
//    var selectedFollowerIndex:Int?
    
    static var allUsers = [String]()
    
    // Managing initiating the number of item in collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == storyCollectionview{
            return (myStories.count)
        }
        else if collectionView == interestCollectionview{
            return myInterestBasedStories.count
        }
        else{
            return ProfileTVC.allUsers.count
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == storyCollectionview {
            selectedStoryIndex = indexPath.row
            performSegue(withIdentifier: "showStoryDetailsFromProfile", sender: self)
        }else if collectionView == interestCollectionview {
            selectedInterestBasedIndex = indexPath.row
            performSegue(withIdentifier: "showInterestBasedStoryDetailsFromProfile", sender: self)
        }else if collectionView == followerCollectionview{
//            selcted
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStoryDetailsFromProfile"{
            if let detailVC = segue.destination as? StoriesDetailVC{
                detailVC.Previouskey = myStories[selectedStoryIndex!].event_key
            }
        }else if segue.identifier == "showInterestBasedStoryDetailsFromProfile"{
            if let detailVC = segue.destination as? StoriesDetailVC{
                detailVC.Previouskey = myInterestBasedStories[selectedInterestBasedIndex!].event_key
            }
        }
    }
    
    // Manages initiating item and related data for the item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // it manages populating story collection view
        if collectionView == storyCollectionview{
            let cell = storyCollectionview.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoriesCVC
            cell.imageview.sd_setImage(with: URL(string: (myStories[indexPath.row].event_image)!), completed: nil )
            cell.title.text = myStories[indexPath.row].event_title
            return cell
            
        }
        // it manages populating interest collection
        else if collectionView == interestCollectionview{
            let cell = interestCollectionview.dequeueReusableCell(withReuseIdentifier: "interestCell", for: indexPath) as! InterestCVC
            print(myInterestBasedStories[indexPath.row].event_title)
            
            //FIXME: ASKED TO MADE Changes So their will be little naming confusion between title and interest
            cell.title.text = myInterestBasedStories[indexPath.row].event_interests
            cell.imageview.sd_setImage(with: URL(string: myInterestBasedStories[indexPath.row].event_image!), completed: nil)
            return cell
        }
        // it manages populating follower collection view
        else if collectionView == followerCollectionview{
            let cell = followerCollectionview.dequeueReusableCell(withReuseIdentifier: "followerCell", for: indexPath) as! FollowersCVC
            cell.imageview.sd_setImage(with: URL(string: ProfileTVC.allUsers[indexPath.row]), completed: nil)
            return cell
        }else{
            return UICollectionViewCell() //Most Probably this statement won't run
        }
        
        
    }
    
    // Variables declared at global score
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var noOfInterests: UILabel!
    @IBOutlet weak var noOfStories: UILabel!
    @IBOutlet weak var noOfFollowers: UILabel!
    
    @IBOutlet weak var profileBG_imageview: UIImageView!
    @IBOutlet weak var profile_imageview: RoundedImage!
    
    @IBOutlet weak var storyCollectionview: UICollectionView!
    @IBOutlet weak var interestCollectionview: UICollectionView!
    @IBOutlet weak var followerCollectionview: UICollectionView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    var locationManager = CLLocationManager()
   
    // method which is called when the first time view controller is launched
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        name.text =  User.singleton.name
//        profile_imageview.sd_setImage(with: URL(string:User.singleton.profileImgURL!), completed: nil)
        
        noOfInterests.text = "\(MyInterestVC.interest.count)"
        noOfFollowers.text = "\(ProfileTVC.allUsers.count)"
        // if there is a picture already saved then it would load from there
        if let image = User.singleton.profileImgURL{
            profile_imageview.sd_setImage(with: URL(string: image), completed: nil)
            profileBG_imageview.sd_setImage(with: URL(string: image), completed: nil)
        }
        
        
        mystories() // fetch and store all stories in the array
        myInterestStories() // fetch and store all interest based stories in the array
        noOfInterests.text = "\(MyInterestVC.interest.count)" // Display on profile page panel no of follower user is following
        
        sidemenu() // enables the ability to interact with sidemenu
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************ProfileTVC**************")
    }

    
    static func getAllUsers(){
        let database = Database.database().reference().child("Users")
        
        database.observe(.value) { (snapshot) in
            
            ProfileTVC.allUsers.removeAll()
            
            
            print(")))))")
            for i in snapshot.children{
            let users = JSON((i as! DataSnapshot).value)
                
                let url = users["profileImageUrl"].stringValue
                if url != nil{
                ProfileTVC.allUsers.append(url)
                }
            }
            
        }
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
            
            revealViewController().rightViewRevealWidth = 275
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())

            
        }
    }
    
    // Fetching and Stores Event + Count Number of Stories
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
    
    // Fetching and Stores Interest based Event + Count Number of Stories
    func myInterestStories(){
        // iterating array of array to loojat events
        for event in HomeTVC.eventArray{
            
            // do the go forward unless it get
            guard let userLocation = self.locationManager.location else {return}
            let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
            
            let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! ))
            let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
            
            //FIXME: MODiFying
            // checking if the distance of event is less than 10km = 10000m
                if self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) <= 10000{
                    var user_interests = MyInterestVC.interest
                    var event_interests = self.stringToArray(string: event.event_interests!)
                    var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                    var common_interests_string = self.commonInterestToString(common: common_interests)
                    
                    // if there are any/some matching interest between user and event
                    if !common_interests.isEmpty{
                        
                        // Assigning pin(Annotation => anno) data from event object obtained from some source
                        anno.title = common_interests_string
                        anno.subtitle = event.event_title
                        
                        
                        anno.event_title = event.event_title
                        anno.event_interests  =  common_interests_string
                        anno.event_image = event.event_image
                        anno.event_noOfAccepted = event.event_noOfAccepted
                        anno.event_noOfDenied = event.event_noOfDenied
                        anno.event_noOfFavourite = event.event_noOfFavourite
                        anno.event_key = event.event_key
                        // added interest based annotation in arraylist
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
        
        let strSet:Set = Set(secondSet.map { $0 })
        //  print(strSet)
        
        let common = userSet.intersection(strSet)
        //  print(common)
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
