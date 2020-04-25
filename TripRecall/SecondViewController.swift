//
//  SecondViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 18/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import GooglePlaces
import SnapKit
import MaterialComponents.MaterialCards
import MaterialComponents.MaterialTabs

class SecondViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, MDCTabBarDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tripsView: UIView!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var tripTableView: UITableView!
    
    var placesClient: GMSPlacesClient!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var trips: [Trip] = []
    let tabBar = MDCTabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        placesClient = GMSPlacesClient.shared()
        
        // Fit topview image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        setupView()
        
//        tabBar.frame = view.bounds
        tabBar.delegate = self
        
        getPlaceDetails(placeID: "ChIJGzE9DS1l44kRoOhiASS_fHg") { (place, error) in
            if let place = place {
                self.locationLabel?.text = "You're in \(place.name!)"
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
        
        trips = self.appDelegate.user!.getPastTrips()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tripTableView.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Private Methods
    
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
        // Add Tabbar
        tabBar.frame = view.bounds
        tabBar.items = [
            UITabBarItem(title: "Past Trips", image: nil, tag: 0),
            UITabBarItem(title: "Next Trips", image: nil, tag: 1),
        ]
        tabBar.itemAppearance = .titles
        tabBar.barTintColor = UIColor(rgb: 0x0a173d)
        tabBar.tintColor = .white
        tabBar.setTitleColor(.white, for: .normal)
        tabBar.setTitleColor(.white, for: .selected)
        tabBar.displaysUppercaseTitles = false
        tabBar.alignment = .justified
        tabBar.sizeToFit()
        tabView.addSubview(tabBar)
        
        let tabLayer = tabView.layer as! MDCShadowLayer
        tabLayer.elevation = ShadowElevation(5)
        
        // Set tableview seperator
        tripTableView.separatorStyle = .none
        tripTableView.showsVerticalScrollIndicator = false
        
        topView.snp.makeConstraints() { (make) in
            make.left.top.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(250)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
        
        locationLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(topView)
            make.left.equalTo(15)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(5)
            make.left.equalTo(15)
        }
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(topView.snp.bottom).offset(0)
            make.height.equalTo(50)
        }

        tripsView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(tabView.snp.bottom).offset(10)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-10)
        }
        
        tripTableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.bottom.equalTo(-10)
        }

    }
    
    // MARK: - Table delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        let trip = trips[indexPath.row]
        
        cell.selectionStyle = .none
        
        cell.tripNameLabel.text = trip.trip_name
        cell.tripDateLabel.text = trip.getTripDates()
        
        self.getPlaceDetails(placeID: trip.place_id) { (place, error) in
            if let place = place {
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
                    cell.cardImage.image = photo
                  }
                })
            }
        }
        
        cell.cardClicked = {
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "TripInfoViewController") as! TripInfoViewController
            destVC.trip = trip
            destVC.tabNo = 1
            destVC.placeImage = cell.cardImage.image
            self.navigationController?.pushViewController(destVC, animated: true)        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - Tab bar delegate
    
    func tabBar(_ tabBar: MDCTabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            trips = self.appDelegate.user!.getPastTrips()
        } else {
            trips = self.appDelegate.user!.getFutureTrips()
        }
        
        tripTableView.reloadData()
    }

}

