//
//  FavouriteVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON
import CoreLocation

class JointVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate {
  
    var selectedIndex:Int?
    
    var locationManager = CLLocationManager()
    
    static var jointInterestArray = [String]()
    static var jointInterestEventArray = [Event]()
    

    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************JointVC**************")
        fetchJoint()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionview.frame.width - 150, height: collectionview.frame.height - 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JointVC.jointInterestEventArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! JointCollectionViewCell
        cell.imageview?.sd_setImage(with: URL(string:JointVC.jointInterestEventArray[indexPath.row].event_image!), completed: nil)
        cell.title.text = JointVC.jointInterestEventArray[indexPath.row].event_title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showJointEventDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsVC = segue.destination as? StoriesDetailVC{
            detailsVC.Previouskey = JointVC.jointInterestEventArray[selectedIndex!].event_key
        }
    }
    
    // enabling functionality of navigation bar buttons
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

    func fetchJoint() {
        let database = Database.database().reference().child("JointInterest").child((Auth.auth().currentUser?.uid)!)
        database.observe(.value) { (snapshot) in
            print("****fetchJoint()****")
           
            JointVC.jointInterestArray.removeAll()
            JointVC.jointInterestEventArray.removeAll()
            
            // Fetch Joint Interests and Removing if interest is out of date
            for i in snapshot.children{
                let joint = JointInterest(json: JSON((i as! DataSnapshot).value), id: (i as! DataSnapshot).key)
//                print(joint.id)
//                print(joint.interest)
//                print(joint.startTime)
//                print(joint.endTime)
                if  AppDelegate.totalSeconds! >= Int(joint.endTime!)!{
                    print(AppDelegate.totalSeconds!)
                    print(Int(joint.endTime!)!)
                    print("time ended")
                    
                    database.child(joint.id!).removeValue()
//                    break
                }else{
                    JointVC.jointInterestArray.append(joint.interest!)
                }
            }
            ////////////////////////
            
            
            // Getting Joint Interests
            for e in HomeTVC.eventArray{
             let common_interests =   self.commonInterest(firstSet: self.stringToArray(string: e.event_interests!), secondSet: JointVC.jointInterestArray)
                
                guard let userLocation = self.locationManager.location else {return}
                let coordinate = CLLocation(latitude: e.event_latitude!, longitude: e.event_longitude!)
                let distanceDifference = self.calculateDistance(mainCoordinate: userLocation , coordinate: coordinate)
                
                // has common interest from joint section & is within radius
                if self.calculateDistance(mainCoordinate: userLocation, coordinate: coordinate) <= 10000 && !common_interests.isEmpty {
                    print("Event Interest: \(e.event_interests)")
                    print("Joint Interest: \(JointVC.jointInterestArray)")
                    print("Common Interest: \(common_interests)")
                    
                    JointVC.jointInterestEventArray.append(e)
                }
            }
            self.loadView()
            self.sidemenu()
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
