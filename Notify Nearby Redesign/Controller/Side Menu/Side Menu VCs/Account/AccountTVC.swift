//
//  AccountVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 04/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import  FirebaseAuth
import FirebaseCore
import SVProgressHUD

class AccountTVC: UITableViewController {

    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************AccountVC**************")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // enables navigation bar buttons functionality
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
//            revealViewController().rightViewRevealWidth = 275
//            notificationBarBtn.target = revealViewController()
//            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
        }
    }
    
    // change the password
    @IBAction func changePasswordPressed(_ sender: Any) {
        
        if password.text == confirmPassword.text{
        let email = Auth.auth().currentUser?.email
        Auth.auth().currentUser?.updatePassword(to: password.text!, completion: nil)
            SVProgressHUD.showSuccess(withStatus: "Password Changed")
        print("Changed Password")
        }else{
            SVProgressHUD.showError(withStatus: "Password not matched")
            print("Passwords not match")
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
