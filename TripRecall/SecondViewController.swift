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

class SecondViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pastHeadingView: UIView!
    @IBOutlet weak var pastHeadingLabel: UILabel!
    @IBOutlet weak var tripTableView: UITableView!
    
    
    var placesClient: GMSPlacesClient!
    let locationNames = ["Hawaii Resort", "Mountain Expedition", "Scuba Diving"]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var trips: [Trip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        placesClient = GMSPlacesClient.shared()
//        searchBar.delegate = self
        setupView()
        
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
        
        pastHeadingView.snp.makeConstraints { (make) in
            make.left.right.equalTo(10)
            make.top.equalTo(topView.snp.bottom).offset(10)
        }
        
        pastHeadingLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
        }
        
    }
    
    // MARK: - Table delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        let trip = trips[indexPath.row]
        
        cell.tripNameLabel.text = trip.trip_name
        cell.tripDateLabel.text = trip.getTripDates()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
 
}

