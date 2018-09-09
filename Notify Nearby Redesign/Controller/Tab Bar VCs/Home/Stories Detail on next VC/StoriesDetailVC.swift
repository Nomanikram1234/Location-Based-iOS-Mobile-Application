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

class StoriesDetailVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{
    
//    var mapview_x:CGFloat?
//    var mapview_y:CGFloat?
//    var mapview_height:CGFloat?
//    var mapview_width:CGFloat?
 
    /* Above is state maintaining code */
    
    @IBOutlet weak var collectionview: UICollectionView!
//    @IBOutlet weak var mapview: MKMapView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! interestStoryDetailCVC
        cell.interest.text = "Interest"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: collectionview.frame.size.width / 4, height: collectionview.frame.size.height - 8)
     
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        mapview_height = mapview.frame.size.height
//        mapview_width = mapview.frame.size.width
//        mapview_x = mapview.frame.origin.x
//        mapview_y = mapview.frame.origin.y
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func mapviewMaximizeBtnPressed(_ sender: Any) {
//        print("view button pressed")
//        UIView.animate(withDuration: 2) {
//
//
//
//        self.mapview.frame.size.width = self.view.frame.width
//        self.mapview.frame.size.height = self.view.frame.height
//
//            self.mapview.layoutSubviews()
//
//        }
//
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
