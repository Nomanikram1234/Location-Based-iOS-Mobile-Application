//
//  ProfileTVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 04/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class ProfileTVC: UITableViewController ,UICollectionViewDelegate,UICollectionViewDataSource , UINavigationControllerDelegate , UIImagePickerControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == storyCollectionview{
          return 5
        }
        else if collectionView == interestCollectionview{
            return 5
        }
        else{
            return 15
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == storyCollectionview{
            let cell = storyCollectionview.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoriesCVC
            cell.imageview.image = UIImage(named: "avatar")
            return cell
            
        }
        else if collectionView == interestCollectionview{
            let cell = interestCollectionview.dequeueReusableCell(withReuseIdentifier: "interestCell", for: indexPath) as! InterestCVC
            cell.imageview.image = UIImage(named: "avatar")
            return cell
        }
        else if collectionView == followerCollectionview{
            let cell = followerCollectionview.dequeueReusableCell(withReuseIdentifier: "followerCell", for: indexPath) as! FollowersCVC
          cell.imageview.image = UIImage(named: "avatar")
            return cell
        }else{
            return UICollectionViewCell()
        }
        
        
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var noOfInterests: UILabel!
    @IBOutlet weak var noOfStories: UILabel!
    @IBOutlet weak var profileBG_imageview: UIImageView!
    @IBOutlet weak var profile_imageview: RoundedImage!
    
    @IBOutlet weak var storyCollectionview: UICollectionView!
    @IBOutlet weak var interestCollectionview: UICollectionView!
    @IBOutlet weak var followerCollectionview: UICollectionView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.text =  User.singleton.name
//        profile_imageview.sd_setImage(with: URL(string:User.singleton.profileImgURL!), completed: nil)
        
        if let image = User.singleton.profileImgURL{
            profile_imageview.sd_setImage(with: URL(string: image), completed: nil)
            profileBG_imageview.sd_setImage(with: URL(string: image), completed: nil)
        }
        
        noOfInterests.text = "\(MyInterestVC.interest.count)"
        
        sidemenu()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
//            revealViewController().rightViewRevealWidth = 160
            
            
        }
    }
    
    
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 1
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
