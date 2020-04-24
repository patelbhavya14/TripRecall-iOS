//
//  FirstViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 18/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import GooglePlaces
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MDCShadowLayer
import MaterialComponents.MaterialCards

class FirstViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tripMsgLabel: UILabel!
    @IBOutlet weak var todayTripView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tripsView: UIView!
    @IBOutlet weak var cardHeading: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardHeaderLabel: UILabel!
    @IBOutlet weak var cardDateLabel: UILabel!
    @IBOutlet weak var addTripButton: MDCButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var placesClient: GMSPlacesClient!
    var cardTrip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.tabBarController?.tabBar.isHidden = false
        
        placesClient = GMSPlacesClient.shared()
        searchBar.delegate = self
        
        // Card image fit to card
        cardImage.translatesAutoresizingMaskIntoConstraints = false
        cardImage.contentMode = .scaleAspectFill
        cardImage.clipsToBounds = true
        cardImage.layer.masksToBounds = true
        cardImage.layer.isOpaque = false
        
        // Set button
        let containerScheme = MDCContainerScheme()
        addTripButton.applyContainedTheme(withScheme: containerScheme)
        addTripButton.backgroundColor = UIColor(rgb: 0x0a173d)
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
        
        nameLabel.text = "Hello, \(appDelegate.user!.username!)."
        
        getTrips()
        
        let ongoingTrips = self.appDelegate.user?.getOngoingTrips()
        let futureTrips = self.appDelegate.user?.getFutureTrips()
        
        tripsView.isHidden = true
        
        if (ongoingTrips!.count) == 0 {
            tripMsgLabel.text = "Sadly, you're not travelling today."
        } else if (ongoingTrips!.count) > 0 {
            tripMsgLabel.text = "Seems like your \(ongoingTrips![0].trip_name) going on."
            cardHeading.text = "Ongoing Trip"
        } else if (futureTrips!.count) == 0 {
            tripMsgLabel.text = "You don't have any planned trips."
        } else if (futureTrips!.count) > 0 {
            tripMsgLabel.text = "Upcoming trip incoming \(self.appDelegate.user!.getFutureTrips().count)!"
            cardHeading.text = "Next Trip"
        }
        
        if let text = cardHeading.text {
            tripsView.isHidden = false
            if text == "Ongoing Trip" {
                setTripCard(placeID: ongoingTrips![0].place_id)
                cardTrip = ongoingTrips![0]
                self.cardDateLabel.text = cardTrip?.getTripDates()
            }
            if text == "Next Trip" {
                setTripCard(placeID: futureTrips![0].place_id)
                cardTrip = futureTrips![0]
                self.cardDateLabel.text = cardTrip?.getTripDates()
            }
        }
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
//
//        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//        destVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//
//        self.present(destVC, animated: true, completion: nil)
        searchBar.endEditing(true)
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    // MARK:- Private Methods
    
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
    
    private func setTripCard(placeID: String) {
        getPlaceDetails(placeID: placeID) { (place, error) in
            if let place = place {
                self.cardHeaderLabel.text = place.name
                
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
                    self.cardImage?.image = photo
                  }
                })
            }
        }
    }
    
    private func setupView() {
        searchView.backgroundColor = UIColor(rgb: 0xe9e9e9)
        searchView.layer.cornerRadius = 10
        searchBar.layer.cornerRadius = 10
        searchBar.barTintColor = UIColor(rgb: 0xe9e9e9)
        searchBar.placeholder = "Where do you want to go?"
        searchBar.searchTextField.backgroundColor = UIColor(rgb: 0xe9e9e9)
        
        let searchLayer = searchView.layer as! MDCShadowLayer
        searchLayer.elevation = ShadowElevation(5)
        
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
        
        searchView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(-20)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(50)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
            make.height.equalToSuperview()
        }
        
        todayTripView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(80)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(0)
            make.width.equalToSuperview()
        }
        
        tripMsgLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(0)
        }
        
        tripsView.snp.makeConstraints { (make) in
            make.top.equalTo(todayTripView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-10)

        }
        
        cardHeading.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
        }
        
        cardView.snp.makeConstraints { (make) in
            make.top.equalTo(cardHeading.snp.bottom).offset(10)
            make.left.right.equalTo(0)
            make.height.equalTo(120)
        }
        
        cardImage.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(0)
            make.width.equalTo(140)
        }

        cardHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cardImage.snp.right).offset(10)
            make.top.equalTo(10)
            make.right.equalTo(0)
        }
        
        cardDateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cardImage.snp.right).offset(10)
            make.top.equalTo(cardHeaderLabel.snp.bottom).offset(5)
            make.right.equalTo(0)
        }
        
        addTripButton.snp.makeConstraints { (make) in
            make.top.equalTo(cardView.snp.bottom).offset(20)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
    }
    
    private func getTrips() {
        let group = DispatchGroup()
         group.enter()
         getDataFromAPI(route: "/v1/trips", method: "GET", access: "private", body: nil) { (result, error) in
             if let result = result {
                 do {
                     let jsonDecoder = JSONDecoder()
                     jsonDecoder.setDateFormat()
                     
                    self.appDelegate.user?.trips = try jsonDecoder.decode([Trip].self, from: result)
                     print("Name : \(self.appDelegate.user!.username ?? "")")
                     print("Rating : \(self.appDelegate.user!.email)")
                 }
                 catch {
                     print("ERROR \(error)")
                 }
             } else if let error = error {
                 print(error)
             }
             group.leave()
         }
         group.wait()
    }
    
    // MARK: - Actions
    
    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "AttractionViewController") as! AttractionViewController
        destVC.trip = cardTrip
        destVC.tabNo = 0
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @IBAction func addTripButtonAction(_ sender: MDCButton) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        destVC.action = "AddTrip"
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
}
