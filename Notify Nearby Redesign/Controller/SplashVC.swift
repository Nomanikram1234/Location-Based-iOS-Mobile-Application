//
//  SpashVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {
    
    /* Variable related to Sign in */
    
    @IBOutlet var signinView: UIView!
    @IBOutlet weak var signinView_email: UITextField!
    @IBOutlet weak var signinView_password: UITextField!
    @IBOutlet weak var signinView_loginBtn: TransparentButton!
    @IBOutlet weak var signinView_signupBtn: UIButton!
    
    
    
    /* Variable related to Sign up */
    
    
    /* Variable related to this View Controller */
    
    @IBOutlet weak var splash_loginBtn: TransparentButton!
    @IBOutlet weak var splash_signupBtn: TransparentButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func splash_loginBtnPressed(_ sender: Any) {
        
        print("Splash: Login Button Pressed")
    }
    
    @IBAction func splash_signupBtnPressed(_ sender: Any) {
        
        print("Splash: Signup Button Pressed")
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
