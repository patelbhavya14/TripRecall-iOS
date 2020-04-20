//
//  FirstViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 18/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import GooglePlaces

class FirstViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        getCurrentPlace()
        // Do any additional setup after loading the view.
        nameLabel.text = appDelegate.user?.username
    }

    // MARK:- Private Methods
    
    private func getCurrentPlace() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
          if let error = error {
            print("Current Place error: \(error.localizedDescription)")
            return
          }

          self.locationLabel.text = "No current place"

          if let placeLikelihoodList = placeLikelihoodList {
            let place = placeLikelihoodList.likelihoods.first?.place
            if let place = place {
              self.locationLabel.text = place.name
            }
          }
        })
    }
}

