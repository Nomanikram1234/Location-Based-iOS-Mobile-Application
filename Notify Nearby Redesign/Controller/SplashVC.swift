//
//  SpashVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

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
    @IBOutlet weak var signupView_usertype: UISegmentedControl!
    
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
    
    
    /* Firebase */
    var auth = Auth.auth() // responsible for managing authentication state of firebase
    let database = Database.database().reference() // stores the reference to firebase database
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // Do any additional setup after loading the view.
        
//        login(email: "nomanikram0@icloud.com", password: "Nomi1234")
//          login(email: "rajanomanikram@yahoo.com", password: "Nomi1234")
//        login(email: "notify.nearby.fyp@gmail.com", password: "Nomi1234") // advestiser
//        login(email: "maida_ashrafgondal@hotmail.com", password: "tangled123")
    
    }

    
    override func viewDidAppear(_ animated: Bool) {
        print("*************SplashVC**************")
        
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
        v?.frame.origin.y = (v?.frame.origin.y)! - 100 // moving up the view 100px up from the center
        self.view.addSubview(v!)
        
        // animating
        UIView.animate(withDuration: 1) {
            self.blackBG.alpha = 0.4
            self.splash_loginBtn.alpha = 0
            self.splash_signupBtn.alpha = 0
        }
      resetSigninFields()
    }
    
    
    /***********   Sign In View    ***************/
    @IBAction func signinView_loginBtnPressed(_ sender: Any) {
        print("Login View: Login Button Pressed")
       
        SVProgressHUD.show()
        login(email: signinView_email.text! , password: signinView_password.text!)
        
      
    }
    
    @IBAction func signinView_signupBtnPressed(_ sender: Any) {
        
        
        // adding signup view
        let v = self.signupView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 100 // moving up the view 100px up from the center
        v?.alpha = 0 // alpha = 0 means its invisible
        self.view.addSubview(v!)
        
        UIView.animate(withDuration: 2) {
            // removing previous view i.e. signin view
            for view in self.view.subviews{
                if view == self.signinView{
                    view.removeFromSuperview()
                }
            }
            
            v?.alpha = 1 // alpha = 1 means its visible
 
        }
  
       
        
        
        
    }
    
    
    @IBAction func signinView_forgottenPassword(_ sender: Any) {
        
        // adding signup view
        let v = self.resetView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 50 // moving up the view 50px up from the center
        v?.alpha = 0 // alpha = 0 means its invisible
        self.view.addSubview(v!) // add reset view(window) on the screen
        
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
        if signupView_password.text! == signupView_confirmPassword.text!{
            
        SVProgressHUD.show()
        createNewUser(email: signupView_email.text!, password: signupView_password.text!, name: signupView_name.text!, contact: signupView_contact.text!)
            
    
        }else{
            print("Signup Failure: Password Not Match")
        }
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
        resetSignupFields()
    }
    
    /****** Reset ******/
    
    @IBAction func resetView_resetBtn(_ sender: Any) {
        print("Reset View: Reset Button Pressed")
        
        SVProgressHUD.show()
        resetPassword(email: resetView_email.text!)
        
    }
    @IBAction func resetView_cancelBtn(_ sender: Any) {
        
        print("Reset View: Cancel Button Pressed")
        
        // adding signin view
        let v = self.signinView
        v?.center = self.view.center
        v?.frame.origin.y = (v?.frame.origin.y)! - 50
        v?.alpha = 0
        self.view.addSubview(v!)
        
        
        UIView.animate(withDuration: 1) {
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
        
        auth.currentUser?.sendEmailVerification(completion: { (error) in
            if error == nil{
                print("Email Verification Sent")
                
                self.verificationView_email.text = ""
                
                // Initializing sign in view
                let v = self.signinView
                v?.alpha = 0
                v?.center = self.view.center
                v?.frame.origin.y = (v?.frame.origin.y)! - 50
                self.view.addSubview(v!)
                
                UIView.animate(withDuration: 1, animations: {
                    for view in self.view.subviews{
                        if view == self.verificationView{
                            view.removeFromSuperview()
                        }
                        v?.alpha = 1
                    }
                })
 
            }else{
                SVProgressHUD.showError(withStatus: "Email Verification failed to Send")
                print("Email Verification failed to Send")
            }
        })
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
                if view == self.verificationView{
                    view.removeFromSuperview()
                }
            }
            
            v?.alpha = 1
        }
    }
    
    /**FIREBASE**/
    func createNewUser(email:String,password:String , name:String ,contact:String){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil{
                print("User Created Successfully")
             
                // If first first tab/segment is selected
                if self.signupView_usertype.selectedSegmentIndex == 0{
                
                    let data = ["name":name,
                                "email":email,
                                "contact":contact,
                                "userType":"user"]
                
                self.database.child("Users").child((self.auth.currentUser?.uid)!).setValue(data)
             
                }
                // if second tab/ segment is selected
                else if self.signupView_usertype.selectedSegmentIndex == 1{
                    
                    let data = ["name":name,
                                "email":email,
                                "contact":contact,
                                "userType":"advertiser"]
                    
                    self.database.child("Users").child((self.auth.currentUser?.uid)!).setValue(data)
                    
                }
                
                SVProgressHUD.dismiss()
                
                // Sending email verification
                self.auth.currentUser?.sendEmailVerification(completion: { (error) in
                    if error == nil{
                        let alertcontroller = UIAlertController(title: "Alert", message: "Verify Your Email Address", preferredStyle: .alert)
                        alertcontroller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        self.present(alertcontroller, animated: true, completion: nil)
                        
                        print("Email Verification Sent")
                    }else{
                        print("Email Verification Failed to Send")
                    }
                })
                
                
                // Animation
                
                // Initializing Sign In View
                let v = self.signinView
                v?.alpha = 0
                v?.center = self.view.center
                v?.frame.origin.y = (v?.frame.origin.y)! - 100
                self.view.addSubview(v!)
                
                
                // removing signup view
                UIView.animate(withDuration: 1) {
                    
                    for view in self.view.subviews{
                        if view == self.signupView{
                            view.removeFromSuperview()
                        }
                    }
                    
                    v?.alpha = 1
                }
                
                // signout the current signed in uid
                do
                {
                    try self.auth.signOut()
                }
                catch{
                    print("Signout Failure ")
                }
                
                // reset fields
                self.resetSignupFields()
            
                
            }else{
                print("Registration Failed")
                SVProgressHUD.showError(withStatus: "Registration Failed")
            }
            
        }
    }
    
    
    
    // Login
    func login(email:String,password:String){
        SVProgressHUD.show()
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if error == nil {
                SVProgressHUD.dismiss()
                
                print("Login Success")
                
                // Email Verification
                if (self.auth.currentUser?.isEmailVerified)! {
                    print("Email is Verified")
                    
                    
                    
                    // Intiantiate Main Screen
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.present(vc, animated: true, completion: nil)
                    
                    SVProgressHUD.dismiss()
                    
                }else{
                    SVProgressHUD.dismiss()
                  
                    print("Email is not Verified")
                    
                    SVProgressHUD.showError(withStatus: "Email is Not Verified")
                    
                    // Initializing verigfication view
                    let v = self.verificationView
                    v?.alpha = 0
                    v?.center = self.view.center
                    self.verificationView_email.text = self.signinView_email.text
                    self.view.addSubview(v!)
                    
                    // animating
                    UIView.animate(withDuration: 1, animations: {
                        
                        self.resetSigninFields()
                        
                        // removing signin view
                        for view in self.view.subviews{
                            if view == self.signinView{
                                view.removeFromSuperview()
                            }
                        }
                       
                        
                        v?.alpha = 1
                    })
                    
                    
                 
                    
                }
                
            }else{
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Login Failure")
                print("Login Failure")
            }
        }
    }
    
    
    // reset fields
    func resetSignupFields() {
        self.signupView_usertype.selectedSegmentIndex = 0
        self.signupView_contact.text = ""
        self.signupView_password.text = ""
        self.signupView_confirmPassword.text = ""
        self.signupView_name.text = ""
        self.signupView_email.text = ""
    }
    
    func resetSigninFields(){
        self.signinView_email.text = ""
        self.signinView_password.text = ""
        
    }
    
    func resetPassword(email:String){
    
        auth.sendPasswordReset(withEmail: email) { (error) in
            if error == nil{
                SVProgressHUD.showSuccess(withStatus: "Reset Password Request Successful")
                print("Reset Password Request Successful")
                
                self.resetView_email.text = ""
                
                // Initializing Sign In View
                let v = self.signinView
                v?.alpha = 0
                v?.center = self.view.center
                v?.frame.origin.y = (v?.frame.origin.y)! - 100
                self.view.addSubview(v!)
                
                
                // removing signup view
                UIView.animate(withDuration: 1) {
                    
                    for view in self.view.subviews{
                        if view == self.resetView{
                            view.removeFromSuperview()
                        }
                    }
                    v?.alpha = 1
                }
                
                SVProgressHUD.dismiss()
                
            }else{
                SVProgressHUD.showError(withStatus: "Reset Password Request Failed")
                print("Reset Password Request Failed")
            }
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
