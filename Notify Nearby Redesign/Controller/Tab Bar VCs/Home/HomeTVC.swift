//
//  HomeVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UserNotifications
import SVProgressHUD
import GeoFire


class HomeTVC: UITableViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, MKMapViewDelegate,CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var centerMapOnUserLocationButton: UIButton!
    
//    static var change:Bool = false
    static var adsTitleArray = [String]()
    
    let storyLocation = Database.database().reference().child("StoryLocation")
   
    
    var circle: MKCircle? = nil
    let regionRadius: Double = 10000 // radius of 10km = 10000 would be displayed/centered on screen
 
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus() // it maintains state of location manager when it changes
    
    var eventCalloutView : EventCalloutView!
    var selectedEventIndex:Int?
    
    let auth = Auth.auth() // handles authorization of user in firebase
    let database = Database.database().reference()  // provides reference to database in firebase
    let storageRef = Storage.storage().reference() // provide reference to storage where we want to storage our images
    let uid = Auth.auth().currentUser?.uid // reference to uid(unique identifier for currently logged user)
    
    static var eventArray = [Event]() // this array is for storing/retriving all events
    static var adsArray = [Event]() // this array is for storing/retriving all ads among the events
    
    
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var mapview: MKMapView!
    
    @IBOutlet weak var segmentedcontrols: UISegmentedControl!
    //    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    /************ Additonal View: Ads upload View ******/
    var duration = 30 // this is for the number of days advertiser wants to display their ad
    
    @IBOutlet var addEventAdsView: UIView!
    @IBOutlet weak var addEventAdsView_title: UITextField!
    @IBOutlet weak var addEventAdsView_interests: UITextField!
    
    @IBOutlet weak var addEventAdsView_imageview: UIImageView!
    @IBAction func addEventAdsView_selectImage(_ sender: Any) {
//        let image = UIImagePickerController()
//        image.delegate = self
//        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        self.present(image, animated: true, completion: nil)
        
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.camera
            self.present(image, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(image, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var addEventAdsView_contact: UITextField!
    @IBOutlet weak var addEventAdsView_durationSegmentedControl: UISegmentedControl!
    
    @IBAction func addEventAdsView_durationSegmentedControlPressed(_ sender: Any) {
        if addEventAdsView_durationSegmentedControl.selectedSegmentIndex == 0 {
            duration = 30
        }else if addEventAdsView_durationSegmentedControl.selectedSegmentIndex == 1{
            duration = 90
        }else if addEventAdsView_durationSegmentedControl.selectedSegmentIndex == 2{
            duration = 365
        }
        print(duration)
    }
    
    @IBOutlet weak var addEventAdsView_description: UITextView!
    
    @IBAction func addEventAdsView_uploadButtonPressed(_ sender: Any) {
        print("Event ads upload button pressed")
        
        if addEventAdsView_title.text == "" {
            alertMessage(title: "Failure", message: "Title field is empty")
        }else if addEventAdsView_interests.text == "" {
            alertMessage(title: "Failure", message: "Interest field is empty")
        }else if !(addEventAdsView_contact.text?.count == 11){
            alertMessage(title: "Failure", message: "Mobile number field must not be empty. It must contain 11 digits")
        }else if addEventAdsView_description.text == "" {
            alertMessage(title: "Failure", message: "Description field is empty")
        }else{
//            print("Success")
        
        
        SVProgressHUD.show()
        guard let userLocation = locationManager.location else { return }

        let eventRef = database.child("stories").childByAutoId()
        //        let storiesRef = Database.database().reference().child("stories").childByAutoId()
        let userRef = database.child("Users").child(uid!).child("stories").childByAutoId().setValue(eventRef.key)
        let tempImgRef = storageRef.child("images/\(eventRef.key).jpg")

        // creating metafile which contains information about the image which we will save in the database
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"


        ////////

        // it place the image in the storage on firebase
        tempImgRef.putData(UIImageJPEGRepresentation(addEventView_imageview.image!, 0)!, metadata: metadata) { (data, error) in
            // if image is uploaded successfully and you can say that there is no error
            if error == nil {

                tempImgRef.downloadURL(completion: { (url, error) in

                    // creating dictionary
                    let data = ["uid":"\(self.uid!)",
                        "description":"\(self.addEventAdsView_description.text!)",
                        "title":self.addEventAdsView_title.text,
                        "type":"advertisement",
                        "storypostedby":User.singleton.name,
                        "longitude":"\(userLocation.coordinate.longitude)",
                        "lat":"\(userLocation.coordinate.latitude)",
                        "interest":self.addEventAdsView_interests.text?.lowercased(),//FIXME: lowercased made most recent change
                        "image": "\(url!)",
                        "acceptedNumber":"0",
                        "deniedNumber":"0",
                        "favouriteNumber":"0",
                        "contact":"\(self.addEventAdsView_contact.text!)",
                        "startTime": "\(AppDelegate.totalSeconds!)",
                        "endTime":"\(AppDelegate.totalSeconds! + ( self.duration * 86400))"
                        ] as [String : Any]

                    //                    var storyDic = ["title": self.titleTxt.text!,
                    //                                    "description": self.des.text!,
                    //                                    "uid":uid,
                    //                                    "keywords": self.keyword.text!,
                    //                                    "image": "images/\(eventRef.key).jpg",
                    //                        "lat": self.latitude!,
                    //                        "long": self.longitude!] as [String : Any]

                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "Advertisement Uploaded Sucessfully")
                    print("Image Uploaded: Successfully")
                    eventRef.setValue(data, withCompletionBlock: { (error, ref) in
                        if error == nil {
                             self.resetAdTextField()

                            // Uploading Data to DB then refreshing map
                            for v in self.view.subviews{
                                if v == self.addEventAdsView{
                                    v.removeFromSuperview()
                                }
                                self.fetchEventsAndDisplayOnMap()

                            }

                            UIView.animate(withDuration: 1) {
                                self.blackBgView.alpha = 0
                            }

                        }
                    })
//                    eventRef.setValue(data)


                    //                    /*Ridas*/
                    //                    let ridaData = ["0":"\(userLocation.coordinate.latitude)",
                    //                                    "1":"\(userLocation.coordinate.longitude)"]
                    ////                    print(eventRef)
                    //                    self.database.child("StoryLocation").child("\(eventRef.key)").child("l").setValue(ridaData)

                    let geofire = GeoFire(firebaseRef: self.storyLocation)
                    geofire.setLocation(CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), forKey: "\(eventRef.key)")

                    /*Ridas*/


                })

            }else{
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Ad Uploading Failure")
                print("Image Upload Failure")
            }
        }
        }//else ending here
    }
    @IBAction func addEventAdsView_cancelButtonPressed(_ sender: Any) {
        
        for v in view.subviews{
            if v == addEventAdsView{
                v.removeFromSuperview()
            }
        }
        
        UIView.animate(withDuration: 1) {
            self.blackBgView.alpha = 0
        }
    }
    
    func resetAdTextField()  {
        addEventAdsView_title.text = ""
        addEventAdsView_interests.text = ""
        addEventAdsView_description.text = ""
        addEventAdsView_durationSegmentedControl.selectedSegmentIndex = 0
        addEventAdsView_contact.text = ""
        addEventAdsView_imageview.image = UIImage(named: "no_image_available")
    }
    
    /************Additional View Variables**************/
    @IBOutlet var blackBgView: UIView!
    
    @IBOutlet var addEventView: UIView!
    @IBOutlet weak var addEventView_imageview: UIImageView!
//    @IBOutlet weak var addEventView_selectPhoto: RoundedButton!
    @IBOutlet weak var addEventView_title: UITextField!
    @IBOutlet weak var addEventView_interests: UITextField!
    @IBOutlet weak var addEventView_description: UITextView!
    
    @IBAction func addEventView_uploadBtn(_ sender: Any) {
        
        print("pressed")
        
        if addEventView_title.text == "" {
           alertMessage(title: "Failure", message: "Title field is empty")
        }else if addEventView_interests.text == "" {
            alertMessage(title: "Failure", message: "Interest field is empty")
        }else if addEventView_description.text == ""{
            alertMessage(title: "Failure", message: "Description field is empty")
        }else{
            
            
        SVProgressHUD.show()
        guard let userLocation = locationManager.location else { return }

     let eventRef = database.child("stories").childByAutoId()
//        let storiesRef = Database.database().reference().child("stories").childByAutoId()
        let userRef = database.child("Users").child(uid!).child("stories").childByAutoId().setValue(eventRef.key)
       let tempImgRef = storageRef.child("images/\(eventRef.key).jpg")

        // creating metafile which contains information about the image which we will save in the database
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"


        ////////

        // it place the image in the storage on firebase
            tempImgRef.putData(UIImageJPEGRepresentation(addEventView_imageview.image!, 0)!, metadata: metadata) { (data, error) in
            // if image is uploaded successfully and you can say that there is no error
            if error == nil {

                tempImgRef.downloadURL(completion: { (url, error) in

                    // creating dictionary
                    let data = ["uid":"\(self.uid!)",
                                "description":"\(self.addEventView_description.text!)",
                                "title":self.addEventView_title.text,
                                "type":"story",
                                "storypostedby":User.singleton.name,
                                "longitude":"\(userLocation.coordinate.longitude)",
                                "lat":"\(userLocation.coordinate.latitude)",
                                "interest":self.addEventView_interests.text?.lowercased(),//FIXME: lowercased made most recent change
                                "image": "\(url!)",
                                "acceptedNumber":"0",
                                "deniedNumber":"0",
                                "favouriteNumber":"0",
                                "startTime": "\(AppDelegate.totalSeconds!)",
                                "endTime":"\(AppDelegate.totalSeconds! + 86400)"
                                ] as [String : Any]

//                    var storyDic = ["title": self.titleTxt.text!,
//                                    "description": self.des.text!,
//                                    "uid":uid,
//                                    "keywords": self.keyword.text!,
//                                    "image": "images/\(eventRef.key).jpg",
//                        "lat": self.latitude!,
//                        "long": self.longitude!] as [String : Any]

                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "Story Uploaded Sucessfully")
                    print("Image Uploaded: Successfully")

                    eventRef.setValue(data, withCompletionBlock: { (error, ref) in
                        if error == nil{
                             self.resetStoryTextFields()
                            // Uploading Data to DB then refreshing map
                            for v in self.view.subviews{
                                if v == self.addEventView{
                                    v.removeFromSuperview()
                                }
                                self.fetchEventsAndDisplayOnMap()

                            }

                            UIView.animate(withDuration: 1) {
                                self.blackBgView.alpha = 0
                            }
                        }
                    })
                    eventRef.setValue(data)


//                    /*Ridas*/
//                    let ridaData = ["0":"\(userLocation.coordinate.latitude)",
//                                    "1":"\(userLocation.coordinate.longitude)"]
////                    print(eventRef)
//                    self.database.child("StoryLocation").child("\(eventRef.key)").child("l").setValue(ridaData)

                    let geofire = GeoFire(firebaseRef: self.storyLocation)
                    geofire.setLocation(CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), forKey: eventRef.key!)

                    
//                    geofire.setLocation(CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), forKey: <#T##String#>, withCompletionBlock: <#T##GFCompletionBlock?##GFCompletionBlock?##(Error?) -> Void#>)
                    /*Ridas*/




                })

                self.addEventView_imageview.image = UIImage(named: "no_image_available")

            }else{
              SVProgressHUD.dismiss()
              SVProgressHUD.showError(withStatus: "Story Uploading Failure")
                print("Image Upload Failure")
            }
        }
 
        }//else ending here
    }
    @IBAction func addEventView_cancelBtn(_ sender: Any) {
        
        for v in view.subviews{
            if v == addEventView{
                v.removeFromSuperview()
            }
        }
        
        UIView.animate(withDuration: 1) {
            self.blackBgView.alpha = 0
        }
        
    }
    
    
    func resetStoryTextFields() {
        addEventView_title.text = ""
        addEventView_imageview.image = UIImage(named: "no_image_available")
        addEventView_interests.text = ""
        addEventView_description.text = ""
//        addEventView_imageview.image = UIImage(named: "no_image_available")
    }
    /******************************************************/
    //FIXME: CAMERAROLL
    /*Camera Roll Related*/
    @IBAction func addEventView_imageview(_ sender: Any) {
//        let image = UIImagePickerController()
//        image.delegate = self
//        image.sourceType = UIImagePickerControllerSourceType.camera
//        self.present(image, animated: true, completion: nil)
        
        
        ////
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.camera
            self.present(image, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(image, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
        ////
    }
    
    // choose image from cameraRoll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let theInfo:NSDictionary = info as NSDictionary
        let img:UIImage = theInfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        addEventView_imageview.image = img
        addEventAdsView_imageview.image = img
        self.dismiss(animated: true, completion: nil)
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
    
    /*********************/
    @IBAction func segmentedControlsChanged(_ sender: Any) {
        if segmentedcontrols.selectedSegmentIndex == 0{
            removeCircle()
            guard let userLocation = locationManager.location else { return }
            showCircle(coordinate: userLocation.coordinate, radius: 10000)
            
            removeAnnotations()
            centerMapOnUserLocation()
            DisplayEventsOnMapFromArray()
        }else
        
        if segmentedcontrols.selectedSegmentIndex == 1{
            removeCircle()
            guard let userLocation = locationManager.location else { return }
            showCircle(coordinate: userLocation.coordinate, radius: 10000)
            
            removeAnnotations()
            centerMapOnUserLocation()
            DisplayEventsOnMapFromArray()
        }
        
        if segmentedcontrols.selectedSegmentIndex == 2{
            removeCircle()
            if User.singleton.address_latitude != nil{
            let address_coordinate = CLLocationCoordinate2D(latitude: User.singleton.address_latitude!, longitude: User.singleton.address_longitude!)
            showCircle(coordinate: address_coordinate, radius: 10000)
            }else{
            
                let alertcontroller = UIAlertController(title: "Tip", message: "Set up your address from Profile Setting", preferredStyle: .alert)
                alertcontroller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                present(alertcontroller, animated: true)
                
            }
            
            removeAnnotations()
            centerMapOnAddressLocation()
            DisplayEventsOnMapFromArray()
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
            In ProfileTVC , there is a static array allUsers and static function getAllUsers()
            so we are calling that method here so that allUsers array get populated with data
         */
        ProfileTVC.getAllUsers()
//        fetchEventsAndDisplayOnMap()
//        vie
        
        // this statement gives the responsiblity to this class to handle the map related task
        mapview.delegate = self
        
        
        
        addEventButton.imageView?.contentMode = .redraw
        centerMapOnUserLocationButton.imageView?.contentMode = .redraw
        
        // Timer scheduled to run function alertTips() after 3 seconds
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(alertTips), userInfo: nil, repeats: false)
        
        print("First Start: \(AppDelegate.firstStart)")
        
        
        
//        if  AppDelegate.firstStart == false{
//
//                let alertcontroller = UIAlertController(title: "Tip", message: "Please add interests from sidemenu in order to see interest based pics on the map", preferredStyle: .alert)
//                alertcontroller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
//            present(alertcontroller, animated: true)
////                present(alertcontroller, animated: true, completion: nil)
//            AppDelegate.firstStart = true
//        }

        // Do any additional setup after loading the view.
//        sidemenu()
        
        authorizingLocalNotification() // configured but not being used
        
        
        configureLocationServices()// configuring location services either its authorized or not
        centerMapOnUserLocation() // center the map on users location
        
        tableview.frame.size.height = view.frame.size.height
        
//      Demo Annotation Code
//      let anno = Event(coordinate: CLLocationCoordinate2D(latitude: 33.549803, longitude: 73.122932))
//      anno.title = "Title"
//      anno.subtitle = "Subtitle"
//      anno.coordinate.latitude = 33.549803
//      anno.coordinate.longitude = 73.122932
//      mapview.addAnnotation(anno)

        
        fetchUserDetails() // fetch user related details and store them in user singleton object & geocode (address to coordinates conversion)
        MyInterestVC.fetchUniqueInterest() // static function fetchUniqueInterest() is called which is storing data in static array uniqueInterestArray
        
        MyInterestVC.fetchUserInterests() // static function fetchUserInterests() is called which is storing data in static array interest
//      fetchEventsAndDisplayOnMap()
//      fetchEventsAndDisplayOnMap()
        
    }
    
    @objc func alertTips(){
        print("First Start: \(AppDelegate.firstStart)")
        // if for the first time user has logged in then this condition will run and make the AppDelagate.firstStart = true so that it can donot showup message again
        if  AppDelegate.firstStart == false{
            
            let alertcontroller = UIAlertController(title: "Tip", message: "Please add interests from sidemenu in order to see interest based pics on the map", preferredStyle: .alert)
            alertcontroller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            present(alertcontroller, animated: true)
            //                present(alertcontroller, animated: true, completion: nil)
            AppDelegate.firstStart = true
            UserDefaults.standard.set(AppDelegate.firstStart, forKey: "firstStart")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************HomeTVC**************")
        sidemenu() // enabling sidemenus
        fetchEventsAndDisplayOnMap() // fetching the events and displaying them on the map according to the segmented control selected
    }
   
    
    // Function not being used in actual but incase its getting permission for displaying notifications to the user
    func authorizingLocalNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (bool, error) in
            if error == nil
            {
                print(bool)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // when add event button is pressed then it will show the views accordingly from user or advertiser point of view
    @IBAction func addEvent(_ sender: UIButton) {
        print("called: addEvent()")
        
        // if usertype is user then it would show the story uploading form
        if User.singleton.userType == "user"{
        
        blackBgView.frame.size = view.frame.size
        addEventView.center = view.center
        addEventView.frame.origin.y = 0
        UIView.animate(withDuration: 1) {
            
//            self.view.alpha = 0.4
            self.blackBgView.alpha = 0.4
             self.view.addSubview(self.blackBgView)
             self.view.addSubview(self.addEventView)
        }
        }// if the usertype is advertiser then it will show the advertisement uploading form
        else if User.singleton.userType == "advertiser"{
            blackBgView.frame.size = view.frame.size
            addEventAdsView.center = view.center
            addEventAdsView.frame.origin.y = 0
            UIView.animate(withDuration: 1) {
                
                //            self.view.alpha = 0.4
                self.blackBgView.alpha = 0.4
                self.view.addSubview(self.blackBgView)
                self.view.addSubview(self.addEventAdsView)
        }
        }
        
    }
    
    /**************** USER DETAIL ****************/
    
    func fetchUserDetails(){
        print("Called:fetchUserDetails")
        database.child("Users").child(uid!).observe(DataEventType.value) { (snapshot) in
            let json = JSON(snapshot.value)
            User.singleton = User.init(json: json)
            print("User Type: \(User.singleton.userType!)")
            
            if User.singleton.address != "" {
            
            
            /* GeoCoding Started */
                
                var geocoder = CLGeocoder()
                geocoder.geocodeAddressString(User.singleton.address!) {
                    placemarks, error in
                    let placemark = placemarks?.first
                    let lat = placemark?.location?.coordinate.latitude
                    let lon = placemark?.location?.coordinate.longitude
                    if lat != nil , lon != nil{
                        print("Lat: \(lat!), Lon: \(lon!)")
                        
                        User.singleton.address_latitude = lat!
                        User.singleton.address_longitude = lon!
                    }else{
                        print("Error")
                        
                        guard let userLocation = self.locationManager.location else {return}
                        User.singleton.address_latitude = userLocation.coordinate.latitude
                        User.singleton.address_longitude = userLocation.coordinate.longitude
                    }
                    
                }
                
                /* GeoCoding End */
            
            }
            
        }
    }
    
    /**************** EVENT ****************/
   func fetchEventsAndDisplayOnMap() {
    
        HomeTVC.eventArray.removeAll()
        HomeTVC.adsArray.removeAll()
//        HomeTVC.adsTitleArray.removeAll()
    
    
        print("fetchEventsAndDisplayOnMap")
        database.child("stories").observe(DataEventType.value) { (snapshot) in
            HomeTVC.eventArray.removeAll()
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
                if self.segmentedcontrols.selectedSegmentIndex == 0{
                    
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
                            anno.event_noOfAccepted = event.event_noOfAccepted
                            anno.event_noOfDenied = event.event_noOfDenied
                            anno.event_noOfFavourite = event.event_noOfFavourite
                            
                            
                            if event.event_endTime == ""{
                                continue
                            }
                            
                            if event.event_endTime == nil{
                                continue
                            }
                           
                            if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                                self.database.child("stories").child(event.event_key!).removeValue()
                                continue
                            }
                            
                            self.collectionview.reloadData()
//                            view.reloadInputViews()
//                            self.localNotification(title: event.event_title, subtitle: event.event_title, body: common_interests_string, lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
                            
                            self.mapview.addAnnotation(anno)
                        }
                        //FIXME: - Local Notification
                        
                        
                        
                        print("Pin inside 10km radius , Distance Difference: \(Int(distanceDifference))")
                        print("User Interests: \(user_interests)")
                        print("Event Interests: \(event_interests)")
                        print ( "Common Interests: \(self.commonInterest(firstSet: user_interests, secondSet: event_interests))")
                        print()
                        self.collectionview.reloadData()
                        
                    }
                    
                }
                
                
                // if AROUND is selected in segmented controls
                if self.segmentedcontrols.selectedSegmentIndex == 1{
                
                if self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) <= 10000
                {
                    var user_interests = MyInterestVC.interest
                    var event_interests = self.stringToArray(string: event.event_interests!)
                    var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                    var common_interests_string = self.commonInterestToString(common: common_interests)
                    
                print("Pin inside 10km radius , Distance Difference: \(Int(distanceDifference))")
                    
                anno.title = event.event_title
                anno.subtitle = event.event_interests
                    
                    
                    
                    anno.event_title = event.event_title
                    anno.event_interests  =  common_interests_string
                    anno.event_key = event.event_key
                    anno.event_image = event.event_image
                    anno.event_noOfAccepted = event.event_noOfAccepted
                    anno.event_noOfDenied = event.event_noOfDenied
                    anno.event_noOfFavourite = event.event_noOfFavourite
                    
                    if event.event_endTime == nil{
                        continue
                    }
                    
                    if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                        self.database.child("stories").child(event.event_key!).removeValue()
                        continue
                    }
                    
                    if event.event_type == "advertisement"{
                        HomeTVC.adsArray.append(event)
                    }
//
//                    self.localNotification(title: event.event_title, subtitle: event.event_title, body: common_interests_string, lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
                self.mapview.addAnnotation(anno)
                }
                 
            }
                
                
                if self.segmentedcontrols.selectedSegmentIndex == 2{
                    print("ADDRESS")
                    
                    let address_coordinate = CLLocation(latitude: User.singleton.address_latitude!, longitude: User.singleton.address_longitude!)
                    
                    if self.calculateDistance(mainCoordinate: address_coordinate , coordinate: coordinate) <= 10000
                    {
                        var user_interests = MyInterestVC.interest
                        var event_interests = self.stringToArray(string: event.event_interests!)
                        var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                        var common_interests_string = self.commonInterestToString(common: common_interests)
                        
                        print("Pin inside 10km radius , Distance Difference: \(Int(distanceDifference))")
                        
                        anno.title = event.event_title
                        anno.subtitle = event.event_interests
                        
                        
                        
                        anno.event_title = event.event_title
                        anno.event_interests  =  common_interests_string
                        anno.event_key = event.event_key
                        anno.event_image = event.event_image
                        anno.event_noOfAccepted = event.event_noOfAccepted
                        anno.event_noOfDenied = event.event_noOfDenied
                        anno.event_noOfFavourite = event.event_noOfFavourite
                        
                        
                        if event.event_endTime == nil{
                            continue
                        }
                        
                        if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                            self.database.child("stories").child(event.event_key!).removeValue()
                            continue
                        }
                        
                        if event.event_type == "advertisement"{
                            HomeTVC.adsArray.append(event)
                        }
                        //
                        //                    self.localNotification(title: event.event_title, subtitle: event.event_title, body: common_interests_string, lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
                        self.mapview.addAnnotation(anno)
                    }
                    
                }
                
              
                
                //FIXME: - Local Notification
//                let content = UNMutableNotificationContent()
                
                //        var badge = 0
                
//                content.title = "New Event is observed nearby"
//                content.subtitle = "\(event.event_title)"
//                content.body = "\(common_interests_string)"
//                content.badge = 1
//                content.sound = UNNotificationSound.default()
//                //        content.
//
////                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
//
//                let center = CLLocationCoordinate2D(latitude: 37.335400, longitude: -122.009201)
//                let region = CLCircularRegion(center: center, radius: 2000.0, identifier: "Headquarters")
//                region.notifyOnEntry = true
//                region.notifyOnExit = false
//                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
//                let request = UNNotificationRequest(identifier: "IS", content: content, trigger: trigger)
//
//                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
                if event.event_endTime == ""{
                    continue
                }
                
                if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                    self.database.child("stories").child(event.event_key!).removeValue()
                    continue
                }
                
                
                if event.event_type == "advertisement"{
                    HomeTVC.adsTitleArray.append(event.event_title!)
                }
                
                print("Event Type: \(event.event_type!)")
                HomeTVC.eventArray.append(event)
            }
            
        
            
            print("fetchEventsAndDisplayOnMap(): fetched Events")
            print("Event Array: Number of Events -> \(HomeTVC.eventArray.count)")
        }
    }
    
    
    // this is function that changes the appearance for the pin i.e purple or black
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // if the annotation is representing user's current position then it would not change any thing. it will simply return
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.displayPriority = .required
        if annotationView == nil{
            //            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView.canShowCallout = false
        }else{
            annotationView.annotation = annotation
        }
        
        //        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        // Setting Annotations Image
        
        // if the array adsTitleArray contains the title that event then it would be an Ad hence it would be represented by purple color else black color
        if segmentedcontrols.selectedSegmentIndex == 1 {
            if HomeTVC.adsTitleArray.contains(annotation.title as! String) {
                
                annotationView.markerTintColor = UIColor.red
                //                mapView.reloadInputViews()
                return annotationView
            }else {
                //                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                annotationView.markerTintColor = UIColor.black
                mapView.reloadInputViews()
                return annotationView
            }
        }else   if segmentedcontrols.selectedSegmentIndex == 2 {
            if HomeTVC.adsTitleArray.contains(annotation.title as! String) {
                
                annotationView.markerTintColor = UIColor.red
                //                mapView.reloadInputViews()
                return annotationView
            }else {
                //                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                annotationView.markerTintColor = UIColor.black
                mapView.reloadInputViews()
                return annotationView
            }
        }
            
            // Since we are replace the title with subtitle in segments so so we are interchanging their color
        else{
            if HomeTVC.adsTitleArray.contains(annotation.subtitle as! String) {
                //                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                annotationView.markerTintColor = UIColor.red
                //                 mapView.reloadInputViews()
                return annotationView
            }else {
                //                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                annotationView.markerTintColor = UIColor.black
                //                 mapView.reloadInputViews()
                return annotationView
            }
        }
        
    }


    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
//        annotationView.markerTintColor = UIColor.purple
//        // annotationView.canShowCallout = true
//               HomeTVC.change = true
//            return annotationView
//    }
  
    
    // function not being used
    func localNotification(title:String?,subtitle:String?,body:String?,lat:CLLocationDegrees,long:CLLocationDegrees) {
        let content = UNMutableNotificationContent()
        content.title = title!
        content.subtitle = subtitle!
        content.body = body!
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = CLCircularRegion(center: center, radius: 10000.0, identifier: "Events")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let loc_trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(identifier: "IS", content: content, trigger: loc_trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
  // static function to fetch all the events
  static  func fetchEvents() {
    var locationManager = CLLocationManager()
        Database.database().reference().child("stories").observe(DataEventType.value) { (snapshot) in
            
            // Removing Previous Data from arrays before fetching new data otherwise there will be multiple dulicates of same data
            HomeTVC.eventArray.removeAll()
            HomeTVC.adsArray.removeAll()
            
            // Fetching all stories
            for key in snapshot.children{
                let json = JSON((key as! DataSnapshot).value)
                let id = JSON((key as! DataSnapshot).key).stringValue
                let event = Event(eventId:id , json: json)  // initiazling by parsed json
                
                guard let userLocation = locationManager.location else {return} // getting user's current location
                let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!) // getting event's coordinates
                
                // checking if event is within 10km radius
                if HomeTVC.calculateDistance_s(mainCoordinate: CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), coordinate: coordinate) <= 10000{
                    
                    if event.event_endTime == ""{
                        continue
                    }
                    
                    if event.event_endTime == nil{
                        continue
                    }
                    
                    if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                        continue
                    }
                    
                    // checking if its ad then place it into arrays i.e adsArray , adsTitleArray
                if event.event_type == "advertisement"{
                    HomeTVC.adsArray.append(event)
                    
                    HomeTVC.adsTitleArray.append(event.event_title!)
                }
                }
                
                
                HomeTVC.eventArray.append(event)
               
                
            }
            print("fetchEvents(): fetched Events")
            print("Event Array: Number of Events -> \(HomeTVC.eventArray.count)")
        }
    }
    
    
    func DisplayEventsOnMapFromArray() {
        
//        database.child("stories").observe(DataEventType.value) { (snapshot) in
        
        
        
            // getting events from array
            for event in HomeTVC.eventArray{
                
                guard let userLocation = self.locationManager.location else {return} // getting user location
                let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!) // getting event's location
                
                let anno = Event(coordinate: CLLocationCoordinate2D(latitude: event.event_latitude!, longitude: event.event_longitude! )) // initializing event annotation
                let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) // checking difference b/w distance of user and event

                //FIXME: MODiFying
                if segmentedcontrols.selectedSegmentIndex == 0{
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
                            
                            if event.event_endTime == ""{
                                continue
                            }
                            
                            if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                                database.child("stories").child(event.event_key!).removeValue()
                                continue
                            }
                            
                            self.mapview.addAnnotation(anno)
                        }
                        
                        print(user_interests)
                        print(event_interests)
                        print ( "Common Interests\(self.commonInterest(firstSet: user_interests, secondSet: event_interests))" )
                        print()
                        
                    }
                    
                }else if segmentedcontrols.selectedSegmentIndex == 1{
                if self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate) <= 10000{
                    
                    var user_interests = MyInterestVC.interest
                    var event_interests = self.stringToArray(string: event.event_interests!)
                    var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests)
                    var common_interests_string = self.commonInterestToString(common: common_interests)
                    
                    print("Pin inside 10km radius , Distance Difference: \(Int(distanceDifference))")
                    
                    //Setting up attribute to annotation
                    anno.title = event.event_title
                    anno.subtitle = common_interests_string
                    
                    anno.event_title = event.event_title
                    anno.event_interests  =  common_interests_string
                    anno.event_key = event.event_key
                    anno.event_image = event.event_image!
                    anno.event_noOfAccepted = event.event_noOfAccepted
                    anno.event_noOfDenied = event.event_noOfDenied
                    anno.event_noOfFavourite = event.event_noOfFavourite
                    
                    print()
                    print(event.event_title!)
                    print("Current time: \(AppDelegate.totalSeconds!)")
                    print("End time: \(event.event_endTime!)")
                   
                    
                    if event.event_endTime == ""{
                         print("continued")
                        continue
                    }
                    
                    if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                        database.child("stories").child(event.event_key!).removeValue()
                         print("Removed")
                        continue
                    }
                             self.mapview.addAnnotation(anno)
                    
                    
                    // adding annotation to the map
               
                }
                }
                
                if self.segmentedcontrols.selectedSegmentIndex == 2{
                    print("ADDRESS")
                    
                    if User.singleton.address_latitude != nil {
                    
                    // when user details were fetched it then geocoded the address to coordinates; now we are using the coordinates
                    let address_coordinate = CLLocation(latitude: User.singleton.address_latitude!, longitude: User.singleton.address_longitude!)
                    
                    // checking if events are within radius of 10km
                    if self.calculateDistance(mainCoordinate: address_coordinate , coordinate: coordinate) <= 10000
                    {
                        var user_interests = MyInterestVC.interest
                        var event_interests = self.stringToArray(string: event.event_interests!) // getting interest from strings and separate them by comma & place in array
                        var common_interests = self.commonInterest(firstSet: user_interests, secondSet: event_interests) // find common interests in two array
                        var common_interests_string = self.commonInterestToString(common: common_interests) // changing the common interests array to string
                        
                        print("Pin inside 10km radius , Distance Difference: \(Int(distanceDifference))")
                        
                        // setting up attributes to annotation
                        anno.title = event.event_title
                        anno.subtitle = event.event_interests
                        
                        anno.event_title = event.event_title
                        anno.event_interests  =  common_interests_string
                        anno.event_key = event.event_key
                        anno.event_image = event.event_image
                        anno.event_noOfAccepted = event.event_noOfAccepted
                        anno.event_noOfDenied = event.event_noOfDenied
                        anno.event_noOfFavourite = event.event_noOfFavourite
                        
                        
                        if event.event_endTime == ""{
                            
                            continue
                        }
                        
                        if event.event_endTime == nil{
                         continue
                        }
                        
                        if AppDelegate.totalSeconds! >= Int(event.event_endTime!)!{
                            database.child("stories").child(event.event_key!).removeValue()
                            continue
                        }
                        
                        // if event is ad then place it into adsArray
                        if event.event_type == "advertisement"{
                            HomeTVC.adsArray.append(event)
                        }
                        //
                        //  self.localNotification(title: event.event_title, subtitle: event.event_title, body: common_interests_string, lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
                        self.mapview.addAnnotation(anno)
                    }
                    
                    
                    }
//                    else{
//                        let alertcontroller = UIAlertController(title: "Tip", message: "Please add interests from sidemenu in order to see interest based pics on the map", preferredStyle: .alert)
//                        alertcontroller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
//                        present(alertcontroller, animated: true)
//                    }
                    
                }
                
            }
            print("DisplayEventsOnMapFromArray(): Called ")

//        }
    }
    
    // when cell is selected this method is called
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEventIndex = indexPath.row
        performSegue(withIdentifier: "showAllStoryDetail", sender: self)
        print(indexPath.row)
    }

    // tells how many items are there in collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return HomeTVC.eventArray.count
    }
    
    // tells the content of cell at specific spot or position
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StoriesCollectionViewCell
        cell.imageview.sd_setImage(with: URL(string: "\(HomeTVC.eventArray[indexPath.row].event_image!)"), completed: nil)
        return cell
    }
    
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())

//          revealViewController().rightViewRevealWidth = 160
            
            revealViewController().rightViewRevealWidth = 275
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
        }
    }
    
    // to request the location services at the start of mapVC incase it is not turned on
    func configureLocationServices() {
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else{
            return
        }
    }
    
    
    
    func centerMapOnUserLocation(){
        
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius*2)
        mapview.setRegion(region, animated: true)
        
    }
    
    func centerMapOnAddressLocation(){
        if User.singleton.address_latitude != nil {
          let address_coordinate = CLLocationCoordinate2D(latitude: User.singleton.address_latitude!, longitude: User.singleton.address_longitude!)
//        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(address_coordinate, regionRadius * 2, regionRadius*2)
        mapview.setRegion(region, animated: true)
        }
            
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }

    
    @IBAction func relocateButton(_ sender: UIButton) {
        print("Centered Map on User Location")
        centerMapOnUserLocation()
    }
    
    // Showing Circle of certian radius
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.black
        circleRenderer.alpha = 0.1
        
        return circleRenderer
   
    }
    
    // whenever user changes its position then this
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        removeCircle() // remove radius around the current location
        
        // Uploading User Current Location
//        let data = ["latitude":  userLocation.location?.coordinate.latitude,
//            "longitutde": userLocation.location?.coordinate.longitude]
//        database.child("UserLocation").child(uid!).setValue(data)
//        
//        let ridaData = ["0":  userLocation.location?.coordinate.latitude,
//                    "1": userLocation.location?.coordinate.longitude]
//        database.child("UserLocation").child(uid!).child("l").setValue(ridaData)
        if segmentedcontrols.selectedSegmentIndex == 0{
            showCircle(coordinate: userLocation.coordinate, radius: 10000)
        }
        if segmentedcontrols.selectedSegmentIndex == 1{
            showCircle(coordinate: userLocation.coordinate, radius: 10000)
        }
        if segmentedcontrols.selectedSegmentIndex == 2{
            
            if User.singleton.address_latitude != nil{
              let address_coordinate = CLLocationCoordinate2D(latitude: User.singleton.address_latitude!, longitude: User.singleton.address_longitude!)
              showCircle(coordinate: address_coordinate, radius: 10000)
            }
        }
         // radius in 10000 meters = 10 kms
    }
    
    // when any annotation is selected
    func mapView(_ mapView: MKMapView,didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        
        
        let event = view.annotation as! Event
        let views = Bundle.main.loadNibNamed("EventCalloutView", owner: nil, options: nil)
        eventCalloutView = views?[0] as! EventCalloutView

        eventCalloutView.event_title.text =  event.event_title
        eventCalloutView.event_basedon.text = event.event_interests
        eventCalloutView.event_key.text = event.event_key
        eventCalloutView.event_noOfAccepts.text = event.event_noOfAccepted
        eventCalloutView.event_noOfDenied.text = event.event_noOfDenied
        eventCalloutView.event_noOfFavourite.text = event.event_noOfFavourite
        eventCalloutView.event_imageview.sd_setImage(with: URL(string: event.event_image!), completed: nil)
        print(event.event_image)
        
         eventCalloutView.readMoreButton.addTarget(self, action: #selector(HomeTVC.addEventView_readMoreBtnPressed(sender:)) , for: .touchUpInside)
        
        
        // 3
        eventCalloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -eventCalloutView.bounds.size.height*0.52)
        
        view.addSubview(eventCalloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
    }

    @objc func addEventView_readMoreBtnPressed(sender: UIButton){
        print("Read More Button Pressed")
         performSegue(withIdentifier: "showStoryDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAllStoryDetail"{
            if let StoriesDetailVC = segue.destination as? StoriesDetailVC{
                
                StoriesDetailVC.Previouskey = HomeTVC.eventArray[selectedEventIndex!].event_key
                
                
            }
        }else
        if let StoriesDetailVC = segue.destination as? StoriesDetailVC{
   
            StoriesDetailVC.Previouskey = eventCalloutView.event_key.text
            
            
        }
    }
    
    // When deselect the annotation view
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Annotation Deselected")

        if view.isKind(of: UIView.self)
        {
                view.viewWithTag(1)?.removeFromSuperview()
        }
    }

    
    // show the circle
    func showCircle(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        circle = MKCircle(center: coordinate, radius: radius)
        mapview.add(circle!)
    }
    
    // removes circle overlays present in the view
    func removeCircle() {
        for overlay in mapview.overlays{
            mapview.remove(overlay)
        }
    }
    
    
    //test function
    func removeAnnotations(){
        for annotation in mapview.annotations{
            mapview.removeAnnotation(annotation)
        }
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
    
    func alertMessage(title:String,message:String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
  static func calculateDistance_s(mainCoordinate: CLLocation,coordinate: CLLocation) -> Double{
        
        let distance = mainCoordinate.distance(from: coordinate)
        //        print("Calculate Distance: \(distance)")
        
        return distance
    }
    
    
    
    
    
    
    
    
}




extension MKAnnotationView {
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point)
                if isInside
                {
                    break
                }
            }
        }
        return isInside
    }
    
    
    
}


