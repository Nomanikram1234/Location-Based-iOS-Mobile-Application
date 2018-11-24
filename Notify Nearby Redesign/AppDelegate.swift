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
import FirebaseAuth
import FirebaseCore

import FirebaseMessaging
import UserNotifications
import SwiftyStoreKit

import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate  ,MessagingDelegate {
    
    // variable initiated for the first time login everytime
    static var firstStart :Bool = false
    
    // calculating the time in seconds since 1970
    static var totalSeconds :Int?

    var window: UIWindow?
//    static var arr = [Discovery]()
    
    override init() {
        FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        FirebaseApp.configure()
         setupIAP()
         Messaging.messaging().delegate = self
      
         registerForNotifications(application)
         Messaging.messaging().shouldEstablishDirectChannel = true
    
//        FirebaseApp.configure()
        let timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
        
        
        
//          UserDefaults.standard.set(nil, forKey: "firstStart")
//        UserDefaults.standard.setNilValueForKey("firstStart")
        
        /*
         Note: When we are using UserDefaults.standard then we are actually saving the value locally on device for later use even after app is close and reopen it would give the same value from where our application has left previously
         
         First start = false ; means that it has not logged in before
         
         Here in code below we check if the variable firstStart has the value the assign it to AppDeleagate.first
         else
         Save the value of AppDelagate.firstStart = false to variable firstStart
         as we know that application has not logged in previously so we programmatically try to log out if possible (do-try-catch block allows us to try statements)
         */
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
        
        
      let auth =  Auth.auth().addStateDidChangeListener { (auth, user) in

            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            if user == nil{
                print("User: Nil")
//                AppDelegate.firstStart =
                UserDefaults.standard.set(nil, forKey: "firstStart")
                let controller = storyboard.instantiateViewController(withIdentifier: "SplashVC")
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()

            }else{

                if (Auth.auth().currentUser?.isEmailVerified)! {
                print("User: Exists")
//                AppDelegate.firstStart = false
//                UserDefaults.standard.set(AppDelegate.firstStart, forKey: "firstStart")

                print(Auth.auth().currentUser?.uid)
                let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()
                }
//                    else{//FIXME:  seems like fix to me otherwise you can remove it
//                    let controller = storyboard.instantiateViewController(withIdentifier: "SplashVC")
//                    self.window?.rootViewController = controller
//                    self.window?.makeKeyAndVisible()
//                }


            }
        }
        
        
   /* Do Not try this
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                if (Auth.auth().currentUser?.isEmailVerified)! {
                    print("User: Exists")
                    //                AppDelegate.firstStart = false
                    //                UserDefaults.standard.set(AppDelegate.firstStart, forKey: "firstStart")

                    print(Auth.auth().currentUser?.uid)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "SplashVC")
                    controller.performSegue(withIdentifier: "SWRevealViewController", sender: nil)
//                    let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
//                    self.window?.rootViewController = controller
//                    self.window?.makeKeyAndVisible()
                }
            }
        }
        */
        
        // Fetching the data on background thread
        DispatchQueue.global(qos: .userInteractive).async {
            self.scrapingIslamabad()
//            DispatchQueue.main.async {
//                print("Scraping Isb Completed")
//            }
        }
        // Fetching the data on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.scrapingKarachi()
        
        }
        // Fetching the data on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.scrapingLahore()
//            DispatchQueue.main.async {
//                print("Scraping Lahore Completed")
//            }
        }
        
        
        
//        scrapingIslamabad()
//        scrapingLahore()
//        scrapingKarachi()
        
//        registerForNotifications(application)
        
        return true
    }
    
    // to get total seconds since 1970
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
        print("Will Resign Active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Did Enter Background")
        Messaging.messaging().shouldEstablishDirectChannel = false
      
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("Will Enter Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Did Become Active")
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("Application Terminate")
    }
    
    /* Additional Functions Required for Remote Notification */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error: \(error)")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Token: \(deviceToken)")
        
        let   tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
        print("tokenString: \(tokenString)") // use to test push notification
        
        let newToken = InstanceID.instanceID().token()
        print("newToken: \(newToken)")
    
    }
    
    /* Cloud Messaging */
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let newToken = InstanceID.instanceID().token()
        print("newToken: \(newToken)")
        Messaging.messaging().shouldEstablishDirectChannel = true
//        Messaging.messaging().
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received: \(remoteMessage.appData)")
    }
    
    /* SwiftyStoreKit Configuration */
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    
    /* Remote Notification Configuration */
    func registerForNotifications(_ application: UIApplication) {
        
        //        if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        
        UNUserNotificationCenter.current().delegate = self
      
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        
        //        } else {
        
//                    let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//                    application.registerUserNotificationSettings(settings)
        
        //        }

        application.registerForRemoteNotifications()
        
    }

    
}

