//
//  StoriesDetailVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 09/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class StoriesDetailVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    var Previouskey :String?
    var event:Event?
    var interestArray : [String]?
    
    var commonInt:[String]?
    
    let database = Database.database().reference()
    let auth = Auth.auth()
    let uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var event_title: UILabel!
    
    @IBOutlet weak var event_description: UITextView!
    
    @IBOutlet weak var event_image: UIImageView!
    @IBOutlet weak var deleteButton: TransparentButton!
    @IBOutlet weak var editButton: BlackBorderSmallButton!
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    
    
    
    
//    @IBOutlet weak var mapview: MKMapView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interestArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! interestStoryDetailCVC
        cell.interest.text = interestArray?[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: collectionview.frame.size.width / 4, height: collectionview.frame.size.height - 8)
     
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        print("Report Button Pressed")
    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
         print("Accept Button Pressed")
        
        
        
//        let view = sender.superview as! StoryCalloutView
//        let storyKey = view.sKey.text!
        //        print("Story Key: \(storyKey)")
        
        let acceptedRef =  database.child("stories").child(Previouskey!).child("accepted")
        
        
        acceptedRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            var count = snapshot.childrenCount
            //            print(count)
            
            if count == 0 {
                self.database.child("stories").child(self.Previouskey!).child("accepted").childByAutoId().setValue(self.uid)
                
                self.database.child("Users").child(self.uid!).child("accepted").childByAutoId().setValue(self.Previouskey)
                
                count = snapshot.childrenCount
                
//                view.noOfAccept.text = "\(count+1)"
                self.database.child("stories").child(self.Previouskey!).child("acceptedNumber").setValue("\(count+1)")
            }else{
                
                
                
                
                for id in snapshot.children{
                    if ((id as! DataSnapshot).hasChild(self.uid!)){
                        
                        
                        self.database.child("stories").child(self.Previouskey!).child("accepted").childByAutoId().setValue(self.uid)
                        
                        self.database.child("Users").child(self.uid!).child("accepted").childByAutoId().setValue(self.Previouskey)
                        
                        count = snapshot.childrenCount
                        
//                        view.noOfAccept.text = "\(count+1)"
                        self.database.child("stories").child(self.Previouskey!).child("acceptedNumber").setValue("\(count+1)")
                        
                        //                        print("Extered")
                    }else{
                        //                        print("Already exists")
                        
                        //                        count = snapshot.childrenCount
                        //                        self.databaseRef.child("stories").child(storyKey).child("acceptedNumber").setValue(count+1)
                        
                        return
                    }
                }
            }//else ending
            
            //    count = snapshot.childrenCount
            //   self.databaseRef.child("stories").child(storyKey).child("acceptedNumber").setValue(count)
        }
        
        
    }
    
    @IBAction func rejectButtonPressed(_ sender: Any) {
         print("Reject Button Pressed")
        
        
//        let view = sender.superview as! StoryCalloutView
//        let storyKey = view.sKey.text!
        //        print("Story Key: \(storyKey)")
        
        let deniedRef =  database.child("stories").child(Previouskey!).child("denied")
        
        
        deniedRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            var count = snapshot.childrenCount
            //            print(count)
            
            if count == 0 {
                self.database.child("stories").child(self.Previouskey!).child("denied").childByAutoId().setValue(self.uid)
                
                self.database.child("Users").child(self.uid!).child("denied").childByAutoId().setValue(self.Previouskey)
                
                count = snapshot.childrenCount
                
//                view.noOfDeny.text = "\(count+1)"
                self.database.child("stories").child(self.Previouskey!).child("deniedNumber").setValue("\(count+1)")
            }else{
                
                
                
                
                for id in snapshot.children{
                    if ((id as! DataSnapshot).hasChild(self.uid!)){
                        
                        self.database.child("stories").child(self.Previouskey!).child("denied").childByAutoId().setValue(self.uid)
                        
                        self.database.child("Users").child(self.uid!).child("denied").childByAutoId().setValue(self.Previouskey!)
                        
                        
                        count = snapshot.childrenCount
                        
//                        view.noOfDeny.text = "\(count+1)"
                        self.database.child("stories").child(self.Previouskey!).child("deniedNumber").setValue("\(count+1)")
                        
                        //                        print("Extered")
                    }else{
                        //                        print("Already exists")
                        
                        //                        count = snapshot.childrenCount
                        //                        self.databaseRef.child("stories").child(storyKey).child("deniedNumber").setValue(count+1)
                        
                        return
                    }
                }
            }//else ending
            
            //   count = snapshot.childrenCount
            //self.databaseRef.child("stories").child(storyKey).child("deniedNumber").setValue(count+1)
        }
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
         print("Delete Button Pressed")
        
        database.child("stories").child(Previouskey!).removeValue()
        
        database.child("Users").child(uid!).child("stories").observe(.value) { (snapshot) in
            for snap in snapshot.children{
                // if the selected story is present/matches with the story present in the firebase database then it would delete that story
                if (snap as! AnyObject).value == self.Previouskey{
                    (snap as! AnyObject).ref.removeValue()
                print("Deleted Successfully")
                    self.dismiss(animated: true, completion: {
                        
                    })
                }else{
                    print("Failed to Delete")
                }
            }
            
        }
        
    }

    
    @IBAction func favouriteButtonPressed(_ sender: Any) {
        print("Favourite Button Pressed")
        
        
//        let view = sender.superview as! StoryCalloutView
//        let storyKey = view.sKey.text!
        //        print("Story Key: \(storyKey)")
        
        let favouriteRef =  database.child("stories").child(Previouskey!).child("favourite")
        
        
        favouriteRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            var count = snapshot.childrenCount
            //            print(count)
            
            
            
            
            if count == 0 {
                self.database.child("stories").child(self.Previouskey!).child("favourite").childByAutoId().setValue(self.uid)
                
                self.database.child("users").child(self.uid!).child("favourite").childByAutoId().setValue(self.Previouskey)
                
                count = snapshot.childrenCount
                
//                view.noOfFavourite.text = "\(count+1)"
                self.database.child("stories").child(self.Previouskey!).child("favouriteNumber").setValue("\(count+1)")
            }else{
                
                
                
                
                for id in snapshot.children{
                    
                    
                    
                    if ((id as! DataSnapshot).hasChild(self.uid!)){
                        
                        self.database.child("stories").child(self.Previouskey!).child("favourite").childByAutoId().setValue(self.uid)
                        
                        self.database.child("users").child(self.uid!).child("favourite").childByAutoId().setValue(self.Previouskey)
                        
                        
                        count = snapshot.childrenCount
                        
//                        view.noOfFavourite.text = "\(count+1)"
                        self.database.child("stories").child(self.Previouskey!).child("favouriteNumber").setValue("\(count+1)")
                        
                        //                        print("Extered")
                    }else{
                        //                        print("Already exists")
                        
                        //                        count = snapshot.childrenCount
                        //                        self.databaseRef.child("stories").child(storyKey).child("favouriteNumber").setValue(count+1)
                        
                        return
                    }
                }
            }//else ending
            
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
         print("Edit Button Pressed")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        print("\(Previouskey)")
        
    
        
        for event in HomeTVC.eventArray{
            
            if event.event_key == Previouskey {
                
                print(event.event_key)
                print(Previouskey)
                
                self.event = event
                interestArray = stringToArray(string: event.event_interests!)
//               let commonset =  commonInterest(firstSet: interestArray!, secondSet: MyInterestVC.interest)
//               commonInt =  commonInterestToStringArrayList(common: commonset)
                //                print("\(event.event_title)")
//                let url = URL(
                
                event_title.text = event.event_title
                event_image.sd_setImage(with: URL(string:event.event_image!), completed: nil)
                
                if event.uid == Auth.auth().currentUser?.uid{
                    deleteButton.isHidden == false
                    editButton.isHidden == false
                }else{
                    deleteButton.isHidden == true
                    editButton.isHidden == true
                }
                
                break
            }
        }
        collectionview.reloadData()
//        mapview_height = mapview.frame.size.height
//        mapview_width = mapview.frame.size.width
//        mapview_x = mapview.frame.origin.x
//        mapview_y = mapview.frame.origin.y
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
//    MARK: - GETTING common Interest

    //1: converting string to string array
    func stringToArray(string:String)->[String]{
        var string = string
        var removeWhiteSpcSTR = string.replacingOccurrences(of: " ", with: "")
        var strArray : [String] = removeWhiteSpcSTR.components(separatedBy: ",")
        return strArray
    }
//
//    //2: finding common interest from two string arrays
//    func commonInterest(firstSet:[String],secondSet:[String]) -> Set<String>{
//
//        var userInterest = firstSet
//        let userSet:Set = Set(userInterest.map { $0 })
//
//        //    var str = "Hello, playground, sad, a,as "
//        //    var removeWhiteSpcSTR = str.replacingOccurrences(of: " ", with: "")
//        //    var strArray : [String] = removeWhiteSpcSTR.components(separatedBy: ",")
//
//        let strSet:Set = Set(secondSet.map { $0 })
//        //    print(strSet)
//
//        let common = userSet.intersection(strSet)
//        //        print(common)
//        return common
//    }
//
//    //3: converting common set element to string form for printing
//    func commonInterestToString(common : Set<String>) -> String {
//        var stringers = ""
//        for val in common {
//            stringers = "\(stringers) \(val)"
//        }
//        return stringers
//    }
//
//    //3: converting common set element to arraylistform for printing
//    func commonInterestToStringArrayList(common : Set<String>) -> [String] {
//        var str = [String]()
//
////        var stringers = ""
//        for val in common {
//            str.append(val)
//
//        }
//        return str
//    }
    
    //TODO: To calculate the distance
    func calculateDistance(mainCoordinate: CLLocation,coordinate: CLLocation) -> Double{
        
        let distance = mainCoordinate.distance(from: coordinate)
        //        print("Calculate Distance: \(distance)")
        
        return distance
    }

}
