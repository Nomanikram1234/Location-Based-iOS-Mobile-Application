//
//  MyInterestVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 04/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON

class MyInterestVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var arr = ["interest","traffic","university"] // not being used for now
    static var interest = [String]() // for storing user interests
//    static var interest = [String]()
    
 
    
    @IBOutlet var additional_view: UIView! // additional view for adding new interest
    @IBOutlet weak var interest_name: UITextField! // new interest name would be saved here
    
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    // cancel button pressed in additonal view
    @IBAction func cancelButtonPressed(_ sender: Any) {
        for view in view.subviews{
            if view == additional_view{
                UIView.animate(withDuration: 1) {
                    self.black_view.alpha = 0
                }
                view.removeFromSuperview()
            }
        }
    }
    
    // when add button pressed in addional view
    @IBAction func addInterestPressed(_ sender: Any)
    {
        
        print("Interest View: Additional View -> Add Button Pressed")
        
        
        if !MyInterestVC.interest.contains(interest_name.text!){
        MyInterestVC.interest.append(interest_name.text!)
        tableview.reloadData()
        
        database.child("Users").child(uid!).child("UserInterests").childByAutoId().setValue(interest_name.text?.lowercased()) { (error, ref) in
            if error == nil{
                print("Successfully Uploaded interest to database")
            }else{
                print("Interest Uploading: Operation Failed")
            }
        }
        }else{
            print("Interest Already Exists")
        }
        interest_name.text = ""
        
        UIView.animate(withDuration: 1) {
            for view in self.view.subviews{
                if view ==  self.additional_view{
                    view.removeFromSuperview()
                }
            }
            self.black_view.alpha = 0
        }
    }
    
    /******************** Main  View Related  *************************/
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var black_view: UIView!
    
    let database = Database.database().reference()
    let auth = Auth.auth()
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAndDisplayUserInterests()
        
        // Do any additional setup after loading the view.
        additional_view.layer.cornerRadius = 7
        sidemenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************MyInterestVC**************")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // fetching user interests from database
   static func fetchUserInterests(){
        let database = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
    
        database.child("Users").child(uid!).child("UserInterests").observe(.value) { (snapshot) in
            MyInterestVC.interest.removeAll()
            for snap in snapshot.children{
                let value = (snap as! DataSnapshot).value as! String
                MyInterestVC.interest.append(value )
            }
        }
    }
    
    // fetching and displaying user interest from database to screen
    func fetchAndDisplayUserInterests(){
        database.child("Users").child(uid!).child("UserInterests").observe(.value) { (snapshot) in
            MyInterestVC.interest.removeAll()
            for snap in snapshot.children{
                let value = (snap as! DataSnapshot).value as! String
                MyInterestVC.interest.append(value )
                self.tableview.reloadData()
            }
        }
    }
    
    // it tells how many numbers of rows would be there
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyInterestVC.interest.count
    }
    
    // it tells what data would be there in the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!  MyInterestTableViewCell
        cell.interest_title.text = MyInterestVC.interest[indexPath.row]
        return cell
    }
    
    // related to editing style, for the purpose we are only using deleting style
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete {
            
            // remove the item from the data model
           
            
            database.child("Users").child(uid!).child("UserInterests").observeSingleEvent(of: .value) { (snapshot) in
                
//                print(snapshot.value)
                
                for snap in snapshot.children{
                    if  ((snap as! DataSnapshot).value as! String) == MyInterestVC.interest[indexPath.row]{
                    print((snap as! DataSnapshot).value)
                       (snap as! DataSnapshot).ref.removeValue()
                        MyInterestVC.interest.remove(at: indexPath.row)
                        self.tableview.reloadData()
                        break // it was removing the next references followed by selected index so i was user break to avoid that
                    }
                }
            }

            
            
            // delete the table view row
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
    }
    
  
    // enables the functionality of buttons on navigation bar
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 275
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            
//            view.addGestureRecognizer(revealViewController().panGestureRecognizer())

        }
    }

    //MARK: when add button is pressed from main view
    @IBAction func addButtonPressed(_ sender: BlackBorderSmallButton) {
        view.addSubview(additional_view)
        additional_view.center = view.center
        UIView.animate(withDuration: 1) {
            self.black_view.alpha = 0.5

        }

        print("Pressed")
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
