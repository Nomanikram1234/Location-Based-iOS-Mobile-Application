//
//  AdsVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import SwiftyJSON

class AdsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
  
    var selectedIndex: Int?
    
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************AdsVC**************")
        fetchEvents()
        collectionview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionview.frame.width - 150, height: collectionview.frame.height - 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HomeTVC.adsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AdsCollectionViewCell
        cell.imageview.sd_setImage(with: URL(string: HomeTVC.adsArray[indexPath.row].event_image!), completed: nil)
        cell.title.text =  HomeTVC.adsArray[indexPath.row].event_title
        cell.category.text = HomeTVC.adsArray[indexPath.row].event_author
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showAdDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? StoriesDetailVC{
            detailVC.Previouskey = HomeTVC.adsArray[selectedIndex!].event_key
        }
    }
    
    // enabling the functionality of nav bar buttons
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

    
    func fetchEvents() {
        var locationManager = CLLocationManager()
        Database.database().reference().child("stories").observe(DataEventType.value) { (snapshot) in
            
            //FIXME: TEST DELTE ARRAY
            HomeTVC.eventArray.removeAll()
            HomeTVC.adsArray.removeAll()
            
            for key in snapshot.children{
                let json = JSON((key as! DataSnapshot).value)
                let id = JSON((key as! DataSnapshot).key).stringValue
                let event = Event(eventId:id , json: json)
                
                guard let userLocation = locationManager.location else {return}
                let coordinate = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
                
                if HomeTVC.calculateDistance_s(mainCoordinate: CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), coordinate: coordinate) <= 10000{
                    if event.event_type == "advertisement"{
                        HomeTVC.adsArray.append(event)
                        
                    }
                }
                
                
                HomeTVC.eventArray.append(event)
                
                
            }
            self.loadView()
            self.sidemenu()
            print("fetchEvents(): fetched Events")
            print("Event Array: Number of Events -> \(HomeTVC.eventArray.count)")
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

}
