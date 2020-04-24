//
//  PlaceViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit
import GooglePlaces
import GoogleMaps
import MaterialComponents.MaterialButtons_Theming

class PlaceViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placeDetailView: UIView!
    @IBOutlet weak var PlaceNameLabel: UILabel!
    @IBOutlet weak var placeLocationLabel: UILabel!
    @IBOutlet weak var btn: MDCButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var wishlistBtn: UIButton!
    
    
    var placesClient: GMSPlacesClient!
    var action: String?
    var place_id: String!
    var placeObj: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placesClient = GMSPlacesClient.shared()
        
        // Do any additional setup after loading the view.
        setupView()
        btn.isHidden = true
        if let action = action {
            var btnName = "Add Place to Attraction"
                    
            if action == "AddTrip" {
                btnName = "Add Place for Trip"
            }
                    
            btn.isHidden = false
            btn.setTitle(btnName, for: .normal)
            let containerScheme = MDCContainerScheme()
            btn.applyOutlinedTheme(withScheme: containerScheme)
        }
        
        // Get place detail
        getPlaceDetails(placeID: place_id) { (place, error) in
            if let place = place {
                self.PlaceNameLabel.text = place.name
                self.placeLocationLabel.text = place.formattedAddress
                
                let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
                let map = GMSMapView.map(withFrame: self.mapView.frame, camera: camera)
                self.mapView.addSubview(map)
                
                map.snp.makeConstraints { (make) in
                    make.edges.equalTo(0)
                }
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                marker.title = place.name
                marker.snippet = place.formattedAddress
                marker.map = map
                
                self.placeObj = Place(place_id: self.place_id, place_name: place.name!, place_location: nil)
                
                // Get the metadata for the first photo in the place photo metadata list.
                if let p = place.photos {
                    let photoMetadata: GMSPlacePhotoMetadata = p[0]

                    // Call loadPlacePhoto to display the bitmap and attribution.
                    self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                      if let error = error {
                        // TODO: Handle the error.
                        print("Error loading photo metadata: \(error.localizedDescription)")
                        return
                      } else {
                        // Display the first image and its attributions.
                        self.placeObj?.place_image = photo
                        self.imageView?.image = photo
                      }
                    })
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Methods
    
    private func setupView() {

        placeDetailView.layer.masksToBounds = false
        placeDetailView.layer.cornerRadius = 20
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        mapView.backgroundColor = .gray
        
        topView.snp.makeConstraints() { (make) in
            make.left.top.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(250)
        }
            
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(5)
            make.left.equalTo(15)
        }
        
        wishlistBtn.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(5)
            make.right.equalTo(-15)
        }
        
        placeDetailView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(-20)
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-5)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        informationView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(40)
        }
        
        PlaceNameLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(0)
        }
        
        placeLocationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(PlaceNameLabel.snp.bottom).offset(5)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(PlaceNameLabel.snp.right).offset(10)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.centerY.equalToSuperview()
        }
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(informationView.snp.bottom).offset(25)
            make.left.right.equalTo(0)
            make.height.equalTo(300)
            make.width.equalToSuperview()
        }
        
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(mapView.snp.bottom).offset(15)
            make.height.equalTo(50)
            make.width.equalToSuperview()
        }
              
    }
    
    private func getPlaceDetails(placeID: String, completion: @escaping (GMSPlace?, Error?) -> Void) {

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.photos.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))!

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

    private func addAttraction(route: String, body: Data, completion: @escaping (Attraction?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: route, method: "POST", access: "public", body: body) { (result, error) in
            if let result = result {
                do {
                    //create json object from data
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.setDateFormat()
                        
                        let attraction = try jsonDecoder.decode(Attraction.self, from: result)
                        completion(attraction, nil)
                    }
                } catch let error {
                    completion(nil, error)
                    print(error.localizedDescription)
                }
                
            } else if let error = error {
                completion(nil, error)
            }
            group.leave()
        }
        group.wait()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    @IBAction func addTripButtonAction(_ sender: Any) {
        
        if action == "AddTrip" {
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "AddTripViewController") as! AddTripViewController
            destVC.place = placeObj
            self.navigationController?.pushViewController(destVC, animated: true)
            return
        }
        
        let srcVC = self.navigationController?.viewControllers[1] as! AttractionViewController
        let attraction = Attraction(place_id: place_id, date: srcVC.selectedDay.toAttractionDate()!)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.setDateFormat()
                
        do {
            let jsonData = try jsonEncoder.encode(attraction)
                    
            addAttraction(route: "/v1/trip/\(srcVC.trip._id!)/attraction", body: jsonData) { (attraction, error) in
                
                if let attraction = attraction {
                    
                    DispatchQueue.main.async {
                        srcVC.addedAttraction = attraction
                        self.navigationController?.popToViewController(srcVC, animated: true)
                        print("INSERTED SUCCESS")
                    }
                } else if let e = error as? ResponseErrors {
                    print(e)
                } else {
                    print("fatal error")
                }
            }
                    
        } catch {
            print("ERROR IN JSON PARSING \(error)")
        }
    }
    
    @IBAction func bookmarkBtnAction(_ sender: UIButton) {
        sender.setImage(UIImage(named: "bookmark-done"), for: .normal)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
