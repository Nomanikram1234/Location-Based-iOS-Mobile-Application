//
//  AdsVC.swift
//  Notify Nearby Redesign
//
//  Created by Noman Ikram on 03/09/2018.
//  Copyright © 2018 nomanikram. All rights reserved.
//

import UIKit

class AdsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
  
    
    
    @IBOutlet weak var notificationBarBtn: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sidemenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*************AdsVC**************")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionview.frame.width - 150, height: collectionview.frame.height - 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AdsCollectionViewCell
        cell.imageview.image = UIImage(named: "avatar2")
        cell.title.text = "Momina"
        cell.category.text = "Advertisement"
        return cell
    }
    
    // enabling the functionality of nav bar buttons
    func sidemenu(){
        if revealViewController() != nil{
            moreButton.target = revealViewController()
            moreButton.action = #selector(revealViewController().revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            revealViewController().rightViewRevealWidth = 275
            notificationBarBtn.target = revealViewController()
            notificationBarBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
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
