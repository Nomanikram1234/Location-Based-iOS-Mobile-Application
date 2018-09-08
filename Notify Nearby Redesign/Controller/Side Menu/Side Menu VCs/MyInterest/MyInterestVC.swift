//
//  MyInterestVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 04/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class MyInterestVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var additional_view: UIView!
    
    @IBOutlet weak var interest_name: UITextField!
    
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
    
    @IBAction func addInterestPressed(_ sender: Any)
    {
        
        
    }
    
    /*********************************************/
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var black_view: UIView!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        additional_view.layer.cornerRadius = 7
        sidemenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!  MyInterestTableViewCell
        cell.interest_title.text = "Interest title"
      return cell
    }
    
    
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 160
            
        }
    }

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
