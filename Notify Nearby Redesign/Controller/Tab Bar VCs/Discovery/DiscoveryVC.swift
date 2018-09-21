//
//  DiscoveryVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import SDWebImage
import SVProgressHUD

class DiscoveryVC: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var segmentedcontrols: UISegmentedControl!
    
    var isbProcessed = false
    var lahoreProcessed = false
    var karachiProcessed = false
    
    // static arrays to store the data and make them accesible everywhere
    static var arrIslamabad = [Discovery]()
    static var arrLahore = [Discovery]()
    static var arrKarachi = [Discovery]()
    
//    static var countIslamabad = 0
//    static var countRawalpindi = 0
//    static var countKarachi = 0
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Check if threads have not fetched the data*/
        
        if DiscoveryVC.arrIslamabad.count == 0 {
          scrapingIslamabad()
          collectionview.reloadData()
        }
        
        if DiscoveryVC.arrKarachi.count == 0 {
            scrapingKarachi()
//          collectionview.reloadData()
        }
        
        if DiscoveryVC.arrLahore.count == 0 {
            scrapingLahore()
//             collectionview.reloadData()
        }
        
//        collectionview.reloadData()

//        scrapingLahore()
//        scrapingKarachi()
        // Do any additional setup after loading the view.
        sidemenu()
        
    }

    override func viewDidAppear(_ animated: Bool) {
//        print(AppDelegate.arr)
        print("*************DiscoveryVC**************")
        
        collectionview.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 150, height: collectionView.frame.height - 130)
    }
    
    
    @IBAction func segmentedControlsPressed(_ sender: UISegmentedControl) {
        
        
//        if segmentedcontrols.selectedSegmentIndex == 0 {
////            scrapingIslamabad()
//        }else if segmentedcontrols.selectedSegmentIndex == 1{
//            if !lahoreProcessed{
//            scrapingLahore()
//                lahoreProcessed = true
//            }
//        }else if segmentedcontrols.selectedSegmentIndex == 2{
//            if !karachiProcessed{
//            scrapingKarachi()
//                karachiProcessed
//            }
//        }
        
        collectionview.reloadData()
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var counter  = 0
        
        if segmentedcontrols.selectedSegmentIndex == 0{
            counter = DiscoveryVC.arrIslamabad.count
        }else if segmentedcontrols.selectedSegmentIndex == 1{
                counter = DiscoveryVC.arrLahore.count
        }else if segmentedcontrols.selectedSegmentIndex == 2{
                counter = DiscoveryVC.arrKarachi.count
            }
 
        return counter
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoveryCollectionViewCell
     
        if segmentedcontrols.selectedSegmentIndex == 0{
//            print(DiscoveryVC.arrIslamabad[indexPath.row].imageUrl!)
         
            // Activity Indicator Added and setting data to the cell
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.view.addSubview(activityIndicator)
            
            let imgView = cell.viewWithTag(1) as! UIImageView
            imgView.sd_setShowActivityIndicatorView(true)
            imgView.sd_setIndicatorStyle(.gray)
            
            activityIndicator.startAnimating()
            
            cell.imageview.sd_setImage(with: URL(string:DiscoveryVC.arrIslamabad[indexPath.row].imageUrl!), completed: nil) // Functional
            
            activityIndicator.stopAnimating()
            
            cell.eventTitle.text = DiscoveryVC.arrIslamabad[indexPath.row].title // Functional
            cell.eventAddress.text = DiscoveryVC.arrIslamabad[indexPath.row].address // Functional
            cell.eventDate.text = DiscoveryVC.arrIslamabad[indexPath.row].date // Functional
        }else if segmentedcontrols.selectedSegmentIndex == 1{
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoveryCollectionViewCell
//            print(DiscoveryVC.arrLahore[indexPath.row].imageUrl!)
            
            // Activity Indicator Added and setting data to the cell
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.view.addSubview(activityIndicator)
            
            let imgView = cell.viewWithTag(1) as! UIImageView
            imgView.sd_setShowActivityIndicatorView(true)
            imgView.sd_setIndicatorStyle(.gray)
            
            activityIndicator.startAnimating()
            
            
            cell.imageview.sd_setImage(with: URL(string:DiscoveryVC.arrLahore[indexPath.row].imageUrl!), completed: nil)
            
            activityIndicator.stopAnimating()
            
            cell.eventTitle.text = DiscoveryVC.arrLahore[indexPath.row].title
            cell.eventAddress.text = DiscoveryVC.arrLahore[indexPath.row].address
            cell.eventDate.text = DiscoveryVC.arrLahore[indexPath.row].date
        }else if segmentedcontrols.selectedSegmentIndex == 2{
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoveryCollectionViewCell
//            print(DiscoveryVC.arrKarachi[indexPath.row].imageUrl!)
            
            // Activity Indicator Added and setting data to the cell
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.view.addSubview(activityIndicator)
            
            let imgView = cell.viewWithTag(1) as! UIImageView
            imgView.sd_setShowActivityIndicatorView(true)
            imgView.sd_setIndicatorStyle(.gray)
            
            activityIndicator.startAnimating()
            
            cell.imageview.sd_setImage(with: URL(string:DiscoveryVC.arrKarachi[indexPath.row].imageUrl!), completed: nil) // Funtional
            
            activityIndicator.stopAnimating()
            
            cell.eventTitle.text = DiscoveryVC.arrKarachi[indexPath.row].title // Funtional
            cell.eventAddress.text = DiscoveryVC.arrKarachi[indexPath.row].address // Funtional
            cell.eventDate.text = DiscoveryVC.arrKarachi[indexPath.row].date // Funtional
        }
        
        
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoveryCollectionViewCell
//        print(AppDelegate.arr[indexPath.row].imageUrl!)
//        cell.imageview.sd_setImage(with: URL(string:AppDelegate.arr[indexPath.row].imageUrl!), completed: nil)
//        cell.eventTitle.text = AppDelegate.arr[indexPath.row].title
//        cell.eventAddress.text = AppDelegate.arr[indexPath.row].address
//        cell.eventDate.text = AppDelegate.arr[indexPath.row].date
        return cell
    }

   
    
    func scrapingKarachi()  {
//        SVProgressHUD.show()
        
        let urlString = URL(string: "https://allevents.in/karachi/all")
        /////////////////////
        Alamofire.request(URLRequest(url: urlString!)).validate().responseString { (response) in
            let html = response
            do{
                let doc = try SwiftSoup.parse("\(html)")
                let body = doc.body()
                let listview =  try body!.select("div").attr("class", "event-item listview").attr("id", "event-list")
                //                print(body)
                for item in listview{
                    //                    if j.hasAttr("id"){
                    if item.hasAttr("id") && item.hasAttr("typeof"){
                        //                                                print(item)
                        let imgLink = try item.select("img").attr("data-original")
                        
                        let title = try item.select("a").attr("title")
                        let link = try item.select("a").attr("href")
                        let address = try item.select("p").attr("property", "location").attr("class", "location").attr("typeof","Place")
                        var time = try item.select("span").attr("content")
                        time.removeLast(10)
                        
                        
                        // test
                        var addressString = ""
                        for l in address{
                            //                            print(try l.select("span"))
                            for i in try l.select("span"){
                                //                                print(i)
                                addressString = "\(addressString)\(i)"
                            }
                        }
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"name\"> ", with: "")
                        addressString =   addressString.replacingOccurrences(of: "</span>", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"address\" typeof=\"PostalAddress\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"streetAddress\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"address\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "   ", with: " ")
                        addressString =   addressString.replacingOccurrences(of: "  ", with: " ")
                        
//                        print("----------------------------------------------------------------------------- ")
//                        print("Image url: \(imgLink)")
//                        print("Title: \(title)")
//                        print("Address: \(addressString)")
//                        print("url: \(link)")
//                        print(time)
//                        print("")
                        
                        let dis = Discovery()
                        dis.imageUrl = imgLink
                        dis.title = title
                        dis.address = addressString
                        dis.date = time
                        
                        DiscoveryVC.arrKarachi.append(dis)
                        if self.segmentedcontrols.selectedSegmentIndex == 2{
                            self.collectionview.reloadData()
                            SVProgressHUD.dismiss()
                        }
                        SVProgressHUD.dismiss()
                    }
                    //                    }
                    
                }
                
                
            }catch{
                print(error)
            }
            
        }
        
    }
    
    /************Scrapping********************/
    
    func scrapingIslamabad()  {
//        SVProgressHUD.show()
        
        let urlString = URL(string: "https://allevents.in/Islamabad/all")
        /////////////////////
        Alamofire.request(URLRequest(url: urlString!)).validate().responseString { (response) in
            let html = response
            do{
                let doc = try SwiftSoup.parse("\(html)")
                let body = doc.body()
                let listview =  try body!.select("div").attr("class", "event-item listview").attr("id", "event-list")
                //                print(body)
                for item in listview{
                    //                    if j.hasAttr("id"){
                    if item.hasAttr("id") && item.hasAttr("typeof"){
                        //                                                print(item)
                        let imgLink = try item.select("img").attr("data-original")
                        
                        let title = try item.select("a").attr("title")
                        let link = try item.select("a").attr("href")
                        let address = try item.select("p").attr("property", "location").attr("class", "location").attr("typeof","Place")
                        var time = try item.select("span").attr("content")
                        time.removeLast(10)
                        
                        
                        // test
                        var addressString = ""
                        for l in address{
                            //                            print(try l.select("span"))
                            for i in try l.select("span"){
                                //                                print(i)
                                addressString = "\(addressString)\(i)"
                            }
                        }
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"name\"> ", with: "")
                        addressString =   addressString.replacingOccurrences(of: "</span>", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"address\" typeof=\"PostalAddress\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"streetAddress\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"address\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "   ", with: " ")
                        addressString =   addressString.replacingOccurrences(of: "  ", with: " ")
                        
//                        print("----------------------------------------------------------------------------- ")
//                        print("Image url: \(imgLink)")
//                        print("Title: \(title)")
//                        print("Address: \(addressString)")
//                        print("url: \(link)")
//                        print(time)
//                        print("")
                        
                        let dis = Discovery()
                        dis.imageUrl = imgLink
                        dis.title = title
                        dis.address = addressString
                        dis.date = time
                        
                        DiscoveryVC.arrIslamabad.append(dis)
                        if self.segmentedcontrols.selectedSegmentIndex == 0{
                            self.collectionview.reloadData()
                             SVProgressHUD.dismiss()
                        }
                        SVProgressHUD.dismiss()
                    }
                    //                    }
                    
                }
                
                
            }catch{
                print(error)
            }
            
        }
        
    }
    
    func scrapingLahore()  {
//        SVProgressHUD.show()
        
        let urlString = URL(string: "https://allevents.in/lahore/all")
        /////////////////////
        Alamofire.request(URLRequest(url: urlString!)).validate().responseString { (response) in
            let html = response
            do{
                let doc = try SwiftSoup.parse("\(html)")
                let body = doc.body()
                let listview =  try body!.select("div").attr("class", "event-item listview").attr("id", "event-list")
                //                print(body)
                for item in listview{
                    //                    if j.hasAttr("id"){
                    if item.hasAttr("id") && item.hasAttr("typeof"){
                        //                                                print(item)
                        let imgLink = try item.select("img").attr("data-original")
                        
                        let title = try item.select("a").attr("title")
                        let link = try item.select("a").attr("href")
                        let address = try item.select("p").attr("property", "location").attr("class", "location").attr("typeof","Place")
                        var time = try item.select("span").attr("content")
                        time.removeLast(10)
                        
                        
                        // test
                        var addressString = ""
                        for l in address{
                            //                            print(try l.select("span"))
                            for i in try l.select("span"){
                                //                                print(i)
                                addressString = "\(addressString)\(i)"
                            }
                        }
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"name\"> ", with: "")
                        addressString =   addressString.replacingOccurrences(of: "</span>", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"address\" typeof=\"PostalAddress\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"streetAddress\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "<span property=\"address\">", with: "")
                        addressString =   addressString.replacingOccurrences(of: "   ", with: " ")
                        addressString =   addressString.replacingOccurrences(of: "  ", with: " ")
                        
//                        print("----------------------------------------------------------------------------- ")
//                        print("Image url: \(imgLink)")
//                        print("Title: \(title)")
//                        print("Address: \(addressString)")
//                        print("url: \(link)")
//                        print(time)
//                        print("")
                        
                        let dis = Discovery()
                        dis.imageUrl = imgLink
                        dis.title = title
                        dis.address = addressString
                        dis.date = time
                        
                        
                        DiscoveryVC.arrLahore.append(dis)
                        
                        if self.segmentedcontrols.selectedSegmentIndex == 1{
                            self.collectionview.reloadData()
                             SVProgressHUD.dismiss()
                        }
                        SVProgressHUD.dismiss()
                    }
                    //                    }
                    
                }
                
                
            }catch{
                print(error)
            }
            
        }
        
    }
    
    
    // adding functionality to navigation bar buttons
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 275
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
