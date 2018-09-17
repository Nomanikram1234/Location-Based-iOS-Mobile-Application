//
//  EditProfileTVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 17/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class EditProfileTVC: UITableViewController, UINavigationControllerDelegate , UIImagePickerControllerDelegate  {

    @IBOutlet weak var avatarBg_imageview: UIImageView!
    @IBOutlet weak var avatar_imageview: RoundedImage!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var contact: UITextField!
    
    
    
//    @IBOutlet weak var moreButton: UIBarButtonItem!
//    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
//
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        sidemenu()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        name.text = User.singleton.name
        contact.text = User.singleton.contact
        
        
        if let image = User.singleton.profileImgURL{
            avatar_imageview.sd_setImage(with: URL(string: image), completed: nil)
            avatarBg_imageview.sd_setImage(with: URL(string: image), completed: nil)
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    @IBAction func changePhoto(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        let database = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        ////
        let tempImgRef = Storage.storage().reference().child("images/\(uid).jpg")
        
        // creating metafile which contains information about the image which we will save in the database
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
     
           if !(name.text?.isEmpty)!{
        
        tempImgRef.putData(UIImageJPEGRepresentation(avatar_imageview.image!, 0)!, metadata: metadata) { (data, error) in
            // if image is uploaded successfully and you can say that there is no error
            if error == nil {
                
                tempImgRef.downloadURL(completion: { (url, error) in
                    
                    // creating dictionary
//                    let data = ["uid":"\(self.uid!)",
//                        "description":"\(self.addEventView_description.text!)",
//                        "title":self.addEventView_title.text,
//                        "type":User.singleton.userType,
//                        "storypostedby":User.singleton.name,
//                        "longitude":"\(userLocation.coordinate.longitude)",
//                        "lat":"\(userLocation.coordinate.latitude)",
//                        "interest":self.addEventView_interests.text,
//                        "image": "\(url!)",
//                        "acceptedNumber":"0",
//                        "deniedNumber":"0",
//                        "favouriteNumber":"0"
//                        ] as [String : Any]
                    
                    //                    var storyDic = ["title": self.titleTxt.text!,
                    //                                    "description": self.des.text!,
                    //                                    "uid":uid,
                    //                                    "keywords": self.keyword.text!,
                    //                                    "image": "images/\(eventRef.key).jpg",
                    //                        "lat": self.latitude!,
                    //                        "long": self.longitude!] as [String : Any]
                    
                    print("Image Uploaded: Successfully")
//                    eventRef.setValue(data)
                    
                    database.child("Users").child(uid!).child("name").setValue(self.name.text)
                    database.child("Users").child(uid!).child("contact").setValue(self.contact.text)
                    database.child("Users").child(uid!).child("profileImageUrl").setValue("\(url!)")
                    
                    User.singleton.name = self.name.text
        
                    User.singleton.profileImgURL = "\(url!)"
                   
                    // Intiantiate Main Screen
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.present(vc, animated: true, completion: nil)
                    
                })
                
            }else{
                //                SVProgressHUD.showError(withStatus: "Failure")
                print("Image Upload Failure")
            }
        }
        ////
     
        }else{
            print("Name Fields is empty // contact can be empty")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
//    func sidemenu(){
//        if revealViewController() != nil{
//            moreButton.target = revealViewController()
//            moreButton.action = #selector(revealViewController().revealToggle(_:))
//            revealViewController().rearViewRevealWidth = 275
//
//
//            //          revealViewController().rightViewRevealWidth = 160
//
//            revealViewController().rightViewRevealWidth = 275
//            notificationBarBtn.target = revealViewController()
//            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
//
//        }
//    }
    
//    // functions for picking image from CameraRoll
//    @IBAction func uploadImage(_ sender: Any) {
//        let image = UIImagePickerController()
//        image.delegate = self
//        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        self.present(image, animated: true, completion: nil)
//    }
    
    // choose image from cameraRoll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let theInfo:NSDictionary = info as NSDictionary
        let img:UIImage = theInfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        avatar_imageview.image = img
        avatarBg_imageview.image = img
//        imageView.image = img
        self.dismiss(animated: true, completion: nil)
    }
    
    // when we touch outside the textfield then keyboard will disappear
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // when we will touch on return button on key it will hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        // Intiantiate Main Screen
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.present(vc, animated: true, completion: nil)
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
