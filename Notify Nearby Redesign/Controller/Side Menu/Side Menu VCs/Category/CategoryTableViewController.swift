//
//  CategoryTableViewController.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 23/11/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    var selectedIndex:Int?
    var search:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sidemenu()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected Row: \(indexPath.row)")
        
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showList", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchItem(index: selectedIndex!)
        
        if let VC = segue.destination as? CategoryListViewController{
            VC.search = searchItem(index: selectedIndex!)
        }
    }
    
    func searchItem(index:Int) -> String {
        
        if index == 0{
            search = "entertainment"
        }else if index == 1 {
            search = "social"
        }
        else if index == 2 {
            search = "funny"
        }else if index == 3 {
            search = "news"
        }else if index == 4 {
            search = "trip"
        }else if index == 5 {
            search = "games"
        }else if index == 6 {
            search = "sport"
        }else if index == 7 {
            search = "people"
        }
        
//        print("\(search)")
        return search!
    }
    
    
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Side Menu functionality
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 275
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            
            
        }
    }

}
