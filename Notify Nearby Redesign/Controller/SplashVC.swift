//
//  SpashVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class SplashVC: UIViewController ,UITextFieldDelegate{
    
    /* Variable related to Sign in */
    
    @IBOutlet var signinView: UIView!
    
    @IBOutlet weak var signinView_email: UITextField!
    @IBOutlet weak var signinView_password: UITextField!
    
    @IBOutlet weak var signin_forgottonPassword: UIButton!
    
    @IBOutlet weak var signinView_loginBtn: TransparentButton!
    @IBOutlet weak var signinView_signupBtn: UIButton!
    
    /* Variable related to Sign up */
    
    
    @IBOutlet var signupView: UIView!
    
    @IBOutlet weak var signupView_name: UITextField!
    @IBOutlet weak var signupView_email: UITextField!
    @IBOutlet weak var signupView_password: UITextField!
    @IBOutlet weak var signupView_confirmPassword: UITextField!
    @IBOutlet weak var signupView_contact: UITextField!
    
    
    /* Reset View */
    @IBOutlet var resetView: RoundedView!
    
    @IBOutlet weak var resetView_email: UITextField!
    @IBOutlet weak var resetView_resetBtn: TransparentButton!
    @IBOutlet weak var resetView_cancelBtn: BlackBorderSmallButton!
    
    /* Verification View*/
    
    @IBOutlet var verificationView: UIView!
    @IBOutlet weak var verificationView_email: UITextField!
    
    /* Variable related to this View Controller */
    @IBOutlet weak var verificationView_cancelBtn: BlackBorderSmallButton!
    
    @IBOutlet weak var splash_loginBtn: TransparentButton!
    @IBOutlet weak var splash_signupBtn: TransparentButton!
    
    @IBOutlet weak var blackBG: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    /***********Splash Screen***************/
    
    @IBAction func splash_loginBtnPressed(_ sender: Any) {
        
        print("Splash: Login Button Pressed")
        
        // adding signin view
        let v = self.signinView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 50
        self.view.addSubview(v!)
        
        // animating
        UIView.animate(withDuration: 1) {
            self.blackBG.alpha = 0.4
            self.splash_loginBtn.alpha = 0
            self.splash_signupBtn.alpha = 0
            
        }
        
    }
    
    @IBAction func splash_signupBtnPressed(_ sender: Any) {
        
        print("Splash: Signup Button Pressed")
        
        // adding signup view
        let v = self.signupView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 100
        self.view.addSubview(v!)
        
        // animating
        UIView.animate(withDuration: 1) {
            self.blackBG.alpha = 0.4
            self.splash_loginBtn.alpha = 0
            self.splash_signupBtn.alpha = 0
            
        }
        
    }
    
    
    /***********   Sign In View    ***************/
    @IBAction func signinView_loginBtnPressed(_ sender: Any) {
        print("Login View: Login Button Pressed")
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signinView_signupBtnPressed(_ sender: Any) {
        
        
        // adding signup view
        let v = self.signupView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 100
        v?.alpha = 0
        self.view.addSubview(v!)
        
        UIView.animate(withDuration: 2) {
            // removing previous view i.e. signin view
            for view in self.view.subviews{
                if view == self.signinView{
                    view.removeFromSuperview()
                }
            }
            
            v?.alpha = 1
 
        }
  
       
        
        
        
    }
    
    
    @IBAction func signinView_forgottenPassword(_ sender: Any) {
        
        // adding signup view
        let v = self.resetView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 50
        v?.alpha = 0
        self.view.addSubview(v!)
        
        
        
        UIView.animate(withDuration: 1) {
            for view in self.view.subviews{
                if view == self.signinView{
                    view.removeFromSuperview()
                }
            }
            
            v?.alpha = 1
        }
        
    }
    
    
    
     /***********   Sign Up View    ***************/
    
    @IBAction func signupView_signupBtnPressed(_ sender: Any) {
    }
    
    @IBAction func signupView_signinBtnPressed(_ sender: Any) {
   
        // adding signup view
        let v = self.signinView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 100
        v?.alpha = 0
        self.view.addSubview(v!)
        
        // animating
        UIView.animate(withDuration: 2) {
            // removing previous view i.e. signin view
            for view in self.view.subviews{
                if view == self.signupView{
                    view.removeFromSuperview()
                }
            }
            
            v?.alpha = 1
            
        }
        
    }
    
    /****** Reset ******/
    
    @IBAction func resetView_resetBtn(_ sender: Any) {
        print("Reset View: Reset Button Pressed")
    }
    @IBAction func resetView_cancelBtn(_ sender: Any) {
        
        print("Reset View: Cancel Button Pressed")
        
        // adding signin view
        let v = self.signinView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 50
        v?.alpha = 0
        self.view.addSubview(v!)
        
        
        UIView.animate(withDuration: 2) {
            for view in self.view.subviews{
                if view == self.resetView{
                    view.removeFromSuperview()
                }
            }
            
            v?.alpha = 1
        }
    }
    
    
    /******* Verification****/
    
    
    @IBAction func verificationView_sendBtn(_ sender: Any) {
        print("Verification View: Send Button Pressed")
    }
    
    @IBAction func verificationView_cancelButton(_ sender: Any) {
        print("Verification View: Cancel Button Pressed")
        
        // adding signin view
        let v = self.signinView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 50
        v?.alpha = 0
        self.view.addSubview(v!)
        
        
        UIView.animate(withDuration: 2) {
            for view in self.view.subviews{
                if view == self.resetView{
                    view.removeFromSuperview()
                }
            }
            
            v?.alpha = 1
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
