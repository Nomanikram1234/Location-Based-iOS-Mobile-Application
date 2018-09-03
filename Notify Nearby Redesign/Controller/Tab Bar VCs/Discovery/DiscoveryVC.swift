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

class DiscoveryVC: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {
   
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoveryCollectionViewCell
        cell.imageview.image = UIImage(named: "avatar")
        cell.eventTitle.text = "Event"
        cell.eventDescription.text = "ENT DES"
        return cell
    }
    
    func scraping()  {
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
                        
                        print("----------------------------------------------------------------------------- ")
                        print("Image url: \(imgLink)")
                        print("Title: \(title)")
                        print("Address: \(addressString)")
                        print("url: \(link)")
                        print(time)
                        print("")
                    }
                    //                    }
                    
                }
                
                
            }catch{
                print(error)
            }
            
        }
        
    }
    
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 160
            
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
