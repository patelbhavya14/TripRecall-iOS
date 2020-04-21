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
import MaterialComponents.MaterialButtons_Theming

class PlaceViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placeDetailView: UIView!
    @IBOutlet weak var PlaceNameLabel: UILabel!
    @IBOutlet weak var placeLocationLabel: UILabel!
    @IBOutlet weak var btn: MDCButton!
    
    var placesClient: GMSPlacesClient!
    var action: String?
    var place_id: String!
    var placeObj: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placesClient = GMSPlacesClient.shared()
        
        // Do any additional setup after loading the view.
        
        // Get place detail
        getPlaceDetails(placeID: place_id) { (place, error) in
            if let place = place {
                self.PlaceNameLabel.text = place.name!
                self.placeObj = Place(place_id: self.place_id, place_name: place.name!, place_location: nil)
                
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
                    self.placeObj?.place_image = photo
                    self.imageView?.image = photo
                  }
                })
            }
        }
        
        // Setting up a view
        setupView()
        btn.isHidden = true
        if let _ = action {
            btn.isHidden = false
            btn.setTitle("Add Place to Trip", for: .normal)
            let containerScheme = MDCContainerScheme()
            btn.applyContainedTheme(withScheme: containerScheme)
            btn.backgroundColor = UIColor(rgb: 0x0a173d)

            self.placeDetailView.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(placeLocationLabel.snp.bottom).offset(10)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
//        imageView.contentMode = .scaleAspectFit
        
        topView.snp.makeConstraints() { (make) in
            make.left.top.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(250)
        }
            
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
    }
    
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
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "AddTripViewController") as! AddTripViewController
        destVC.place = placeObj
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    

}
