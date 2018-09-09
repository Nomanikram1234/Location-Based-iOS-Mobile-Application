//
//  HomeVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import MapKit

class HomeTVC: UITableViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, MKMapViewDelegate{
 
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    @IBOutlet var tableview: UITableView!
    
    @IBOutlet weak var mapview: MKMapView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
//
//        mapview.layer.frame.size.height = mapview.layer.frame.size.width
//
////        tableview.layer.frame.size.height = view.frame.size.height
//        mapview.layer.cornerRadius = 40
//        mapview.layer.masksToBounds = true
//
//        mapview.layer.shadowColor = UIColor.darkGray.cgColor
//        mapview.layer.shadowOffset = CGSize(width: 0, height: 3)
//        mapview.layer.shadowRadius = 5
//        mapview.layer.shadowOpacity = 0.5
        
//        mapview.clipsToBounds = false
//        mapview.layer.backgroundColor = UIColor.clear.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StoriesCollectionViewCell
        cell.imageview.image = UIImage(named: "avatar4")
        return cell
    }
    
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            

            
            
//            revealViewController().rightViewRevealWidth = 160
            revealViewController().rightViewRevealWidth = 270
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
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
