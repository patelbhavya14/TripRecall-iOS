//
//  ThirdViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons_Theming
import SnapKit
import GooglePlaces

class ThirdViewController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var wishlistButton: MDCButton!
    @IBOutlet weak var logoutButton: MDCButton!
    
    var placesClient: GMSPlacesClient!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placesClient = GMSPlacesClient.shared()
        
        self.buttonsView.backgroundColor = UIColor(patternImage: UIImage(named: "traveller.jpg")!)
        
        // Fit topview image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Set button theme
        let containerScheme = MDCContainerScheme()
        wishlistButton.applyTextTheme(withScheme: containerScheme)
        wishlistButton.setTitleColor(UIColor(rgb: 0x0a173d), for: .normal)
        wishlistButton.setTitleFont(UIFont.boldSystemFont(ofSize: 24.0), for: .normal)
        
        logoutButton.applyTextTheme(withScheme: containerScheme)
        logoutButton.setTitleColor(UIColor(rgb: 0x0a173d), for: .normal)
        logoutButton.setTitleFont(UIFont.boldSystemFont(ofSize: 24.0), for: .normal)
        
        
        setupView()
        
        getPlaceDetails(placeID: "ChIJGzE9DS1l44kRoOhiASS_fHg") { (place, error) in
            if let place = place {
                print("The selected place is: \(place.name!)")
                
                // Get the metadata for the first photo in the place photo metadata list.
                let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

                // Call loadPlacePhoto to display the bitmap and attribution.
                self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                  if let error = error {
                    // TODO: Handle the error.
                    print("Error loading photo metadata: \(error.localizedDescription)")
                    return
                  } else {
                    // Display the first image and its attributions.
                    self.imageView?.image = photo
                  }
                })
            }
        }
        
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
    
    // MARK: - Private methods
    
    private func getPlaceDetails(placeID: String, completion: @escaping (GMSPlace?, Error?) -> Void) {

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.photos.rawValue))!

        placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            completion(nil, error)
            return
          }
          if let place = place {
            completion(place, nil)
          }
        })
    }
    
    private func setupView() {
        topView.snp.makeConstraints() { (make) in
            make.left.top.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(250)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        buttonsView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(0)
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(0)
        }
        
        wishlistButton.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        
        logoutButton.snp.makeConstraints { (make) in
            make.top.equalTo(wishlistButton.snp.bottom).offset(10)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
    }

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func wishlistButtonAction(_ sender: MDCButton) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "WishlistTableViewController") as! WishlistTableViewController
        self.navigationController?.pushViewController(destVC, animated: true)
    }

    @IBAction func logout(_ sender: MDCButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationViewController") as! NavigationViewController
        self.appDelegate.user = nil
        UserDefaults.standard.setValue(nil, forKey: "user_auth_token")
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
}
