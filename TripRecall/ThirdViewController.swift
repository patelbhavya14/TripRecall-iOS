//
//  ThirdViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons_Theming

class ThirdViewController: UIViewController {
    @IBOutlet weak var addTripButton: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let containerScheme = MDCContainerScheme()
        addTripButton.applyContainedTheme(withScheme: containerScheme)
        addTripButton.backgroundColor = UIColor(rgb: 0x0a173d)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func addTripButtonAction(_ sender: MDCButton) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        destVC.action = "AddTrip"
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
