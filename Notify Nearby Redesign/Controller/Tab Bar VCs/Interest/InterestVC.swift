//
//  InterestVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class InterestVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
 
    

    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    @IBOutlet weak var interest_collectionview: UICollectionView!
    
    @IBOutlet weak var commonInterest_collectionview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
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
            
            revealViewController().rightViewRevealWidth = 160
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == interest_collectionview{
        return 5
        }else {
            return 5
        }
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == interest_collectionview{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InterestCollectionViewCell
        cell.imageview.image = UIImage(named: "avatar3")
        cell.title.text = "Momina"
        return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "interest_cell", for: indexPath) as! TopInterestCollectionViewCell
            
            cell.name.text = "Interest"
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == interest_collectionview{
        return CGSize(width: interest_collectionview.frame.width - 150, height: interest_collectionview.frame.height - 130)
        }else{
            return CGSize(width: commonInterest_collectionview.frame.size.width / 4, height: commonInterest_collectionview.frame.size.height - 8)
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
