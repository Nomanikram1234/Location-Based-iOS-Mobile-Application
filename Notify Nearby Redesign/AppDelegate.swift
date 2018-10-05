//
//  AppDelegate.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 01/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // variable initiated for the first time login everytime
    static var firstStart :Bool = false
    
    // calculating
    static var totalSeconds :Int?

    var window: UIWindow?
//    static var arr = [Discovery]()
    
    override init() {
       
        
//        var date = Date()
//        AppDelegate.totalSeconds = Int(date.timeIntervalSince1970 * 1000) / 1000
        
        FirebaseApp.configure()       
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        FirebaseApp.configure()
        
        let timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
        
        
        
//          UserDefaults.standard.set(nil, forKey: "firstStart")
//        UserDefaults.standard.setNilValueForKey("firstStart")
        if UserDefaults.standard.bool(forKey: "firstStart") {
        AppDelegate.firstStart = UserDefaults.standard.bool(forKey: "firstStart")
            
        }else{
        UserDefaults.standard.set(AppDelegate.firstStart, forKey: "firstStart")
            do{
                try Auth.auth().signOut()
            }catch{
                print(error)
            }
        }
        
        
        
        ////////////////////////////
        
        
//      let auth =  Auth.auth().addStateDidChangeListener { (auth, user) in
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//            if user == nil{
//                print("User: Nil")
////                AppDelegate.firstStart =
//                UserDefaults.standard.set(nil, forKey: "firstStart")
//                let controller = storyboard.instantiateViewController(withIdentifier: "SplashVC")
//                self.window?.rootViewController = controller
//                self.window?.makeKeyAndVisible()
//
//            }else{
//
//                if (Auth.auth().currentUser?.isEmailVerified)! {
//                print("User: Exists")
////                AppDelegate.firstStart = false
////                UserDefaults.standard.set(AppDelegate.firstStart, forKey: "firstStart")
//
//                print(Auth.auth().currentUser?.uid)
//                let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
//                self.window?.rootViewController = controller
//                self.window?.makeKeyAndVisible()
//                }
////                    else{//FIXME:  seems like fix to me otherwise you can remove it
////                    let controller = storyboard.instantiateViewController(withIdentifier: "SplashVC")
////                    self.window?.rootViewController = controller
////                    self.window?.makeKeyAndVisible()
////                }
//
//
//            }
//        }
       /////////////////////
        
   
        
//
//        Auth.auth().addStateDidChangeListener() { auth, user in
//            // 2
//            if user != nil {
//                // 3
//                if (Auth.auth().currentUser?.isEmailVerified)! {
//                    print("User: Exists")
//                    //                AppDelegate.firstStart = false
//                    //                UserDefaults.standard.set(AppDelegate.firstStart, forKey: "firstStart")
//
//                    print(Auth.auth().currentUser?.uid)
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let controller = storyboard.instantiateViewController(withIdentifier: "SplashVC")
//                    controller.performSegue(withIdentifier: "SWRevealViewController", sender: nil)
////                    let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
////                    self.window?.rootViewController = controller
////                    self.window?.makeKeyAndVisible()
//                }
//            }
//        }
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.scrapingIslamabad()
//            DispatchQueue.main.async {
//                print("Scraping Isb Completed")
//            }
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.scrapingKarachi()
        
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.scrapingLahore()
//            DispatchQueue.main.async {
//                print("Scraping Lahore Completed")
//            }
        }
        
        
        
//        scrapingIslamabad()
//        scrapingLahore()
//        scrapingKarachi()
        
        return true
    }
    
    @objc func timeUpdate(){
        let date = Date()
        AppDelegate.totalSeconds = Int(date.timeIntervalSince1970 * 1000) / 1000
  //      print(AppDelegate.totalSeconds!)
  
        
        /*
         //Note: 86400000 milliseconds are there in 24hours
         //Note: 86400         seconds are there in 24hours
        
        let totalSeconds = AppDelegate.totalSeconds! / 1000;
        let currentSecond = AppDelegate.totalSeconds! % 60;
        let totalMinutes = AppDelegate.totalSeconds! / 60;
        let currentMinute = totalMinutes % 60;
        let totalHours = totalMinutes / 60;
        let currentHour = totalHours % 24;
        print("\(currentHour):\(currentMinute):\(currentSecond)")
       
        
      */

    }
    

    func scrapingKarachi()  {
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
                        
                    }
                    //                    }
                    
                }
                
                
            }catch{
                print(error)
            }
            
        }
        
    }
    
    
    
    func scrapingIslamabad()  {
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
                       
                    }
                    //                    }
                    
                }
                
                
            }catch{
                print(error)
            }
            
        }
        
    }
    
    func scrapingLahore()  {
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
                        
                        
                    }
                    //                    }
                    
                }
                
                
            }catch{
                print(error)
            }
            
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

