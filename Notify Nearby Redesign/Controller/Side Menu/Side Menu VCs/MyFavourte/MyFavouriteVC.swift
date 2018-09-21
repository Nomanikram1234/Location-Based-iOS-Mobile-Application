//
//  MyFavouriteVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 04/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

class MyFavouriteVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{
 
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    static var favouriteEventArray = [Event]()
    var selectedFavouriteEvent :Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchFavourites()
        
        // Do any additional setup after loading the view.
        sidemenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyFavouriteVC.favouriteEventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyFavouriteTableViewCell
        cell.imageview.sd_setImage(with: URL(string:MyFavouriteVC.favouriteEventArray[indexPath.row].event_image!), completed: nil)
        cell.title.text = MyFavouriteVC.favouriteEventArray[indexPath.row].event_title
        cell.type.text = MyFavouriteVC.favouriteEventArray[indexPath.row].event_interests
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func fetchFavourites(){
    let database = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
        
        database.child("Users").child(uid!).child("favourite").observe(.value) { (snapshot) in
            MyFavouriteVC.favouriteEventArray.removeAll()
            
            for snap in snapshot.children{
                let story = (snap as! DataSnapshot).value
                print("Favourite: \(story)")
                
                for event in HomeTVC.eventArray{
                    if story as! String == event.event_key{
                       MyFavouriteVC.favouriteEventArray.append(event)
                        self.tableview.reloadData()
                    }
                }
 
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFavouriteEvent = indexPath.row
        performSegue(withIdentifier: "showFavouriteEventDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let detailVC = segue.destination as? StoriesDetailVC{
            detailVC.Previouskey = MyFavouriteVC.favouriteEventArray[selectedFavouriteEvent!].event_key
        }
    }
    
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
