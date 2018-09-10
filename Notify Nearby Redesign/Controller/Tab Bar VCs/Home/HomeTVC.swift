//
//  HomeVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import MapKit

class HomeTVC: UITableViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, MKMapViewDelegate,CLLocationManagerDelegate{
    
    var circle: MKCircle? = nil
    let regionRadius: Double = 1000
 
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    
     var eventCalloutView : EventCalloutView!
    
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var mapview: MKMapView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
        
        configureLocationServices()
        centerMapOnUserLocation()
        
        let anno = Event(coordinate: CLLocationCoordinate2D(latitude: 33.549803, longitude: 73.122932))
        anno.title = "Title"
        anno.subtitle = "Subtitle"
        anno.coordinate.latitude = 33.549803
        anno.coordinate.longitude = 73.122932
        mapview.addAnnotation(anno)

    
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
    // Showing Circle of certian radius
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.black
        circleRenderer.alpha = 0.1
        
        return circleRenderer
   
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        removeCircle() // remove radius around the current location
        showCircle(coordinate: userLocation.coordinate, radius: 10000) // radius in 10000 meters = 10 kms
    }
    
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

//        storyCalloutView.title.text = story.title
        
         eventCalloutView.readMoreButton.addTarget(self, action: #selector(HomeTVC.test(sender:)) , for: .touchUpInside)
        
        
        // 3
        eventCalloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -eventCalloutView.bounds.size.height*0.52)
        
        view.addSubview(eventCalloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
    }

    @objc func test(sender: UIButton){
        print("TESTing")
    }
    // When select the annotation view
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Annotation Deselected")

        if view.isKind(of: UIView.self)
        {
            print("Annotation Deselected: Kind of UIView")

            print(view.viewWithTag(1)?.frame.origin)

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
        print("Calculate Distance: \(distance)")
        
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
