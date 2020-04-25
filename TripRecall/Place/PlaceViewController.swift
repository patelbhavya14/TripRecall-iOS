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
import MaterialComponents.MaterialSnackbar

class PlaceViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placeDetailView: UIView!
    @IBOutlet weak var PlaceNameLabel: UILabel!
    @IBOutlet weak var placeLocationLabel: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var wishlistBtn: UIButton!
    @IBOutlet weak var photosLabel: UILabel!
    
    
    var placesClient: GMSPlacesClient!
    var action: String?
    var place_id: String!
    var placeObj: Place?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var wishlist: Wishlist?
    var images: [UIImage] = []
    
    // UI Components
    let message = MDCSnackbarMessage()
    
    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        wishlistBtn.setImage(UIImage(named: "bookmark"), for: .normal)
        
        if let w = appDelegate.user!.isPlaceInWishlist(place_id: place_id) {
            wishlist = w
            wishlistBtn.setImage(UIImage(named: "bookmark-done"), for: .normal)
        }
        placesClient = GMSPlacesClient.shared()
        
        // Set collection view
        scrollView.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        // Do any additional setup after loading the view.
        setupView()
        
        btn.isHidden = true
        if let _ = action {
            btn.isHidden = false
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
                    for (idx, photo) in p.enumerated() {
                        let photoMetadata: GMSPlacePhotoMetadata = photo

                        // Call loadPlacePhoto to display the bitmap and attribution.
                        self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                          if let error = error {
                            // TODO: Handle the error.
                            print("Error loading photo metadata: \(error.localizedDescription)")
                            return
                          } else {
                            // Display the first image and its attributions.
                            if idx == 0 {
                                self.placeObj?.place_image = photo
                                self.imageView?.image = photo
                            } else {
                                self.images.append(photo!)
                            }
                          }
                        })
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
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
            make.left.top.equalTo(5)
            make.right.bottom.equalTo(-5)
        }
        
        informationView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(50)
        }
        
        PlaceNameLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(0)
            make.width.equalTo(200)
        }
        
        placeLocationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(PlaceNameLabel.snp.bottom).offset(5)
            make.width.equalTo(200)
        }
        
        btn.snp.makeConstraints { (make) in
//            make.left.equalTo(PlaceNameLabel.snp.right).offset(10)
            make.right.equalTo(0)
//            make.height.width.equalTo(50)
            make.centerY.equalTo(informationView)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(informationView.snp.bottom).offset(25)
            make.left.right.equalTo(0)
            make.height.equalTo(300)
            make.width.equalToSuperview()
        }
        

        photosLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(mapView.snp.bottom).offset(15)
            make.width.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(photosLabel.snp.bottom).offset(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(100)
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
        getDataFromAPI(route: route, method: "POST", access: "private", body: body) { (result, error) in
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
    
    private func wishlistAPI(route: String, method: String, body: Data?, completion: @escaping (Wishlist?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: route, method: method, access: "public", body: body) { (result, error) in
            if let result = result {
                do {
                    //create json object from data
                    do {
                        if method == "DELETE" {
                            completion(self.wishlist, nil)
                        } else {
                            let jsonDecoder = JSONDecoder()
                            jsonDecoder.setDateFormat()
                            
                            let wishlist = try jsonDecoder.decode(Wishlist.self, from: result)
                            completion(wishlist, nil)
                        }
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
        
        let srcVC = self.navigationController?.viewControllers[2] as! AttractionViewController
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
        if let w = self.wishlist {
            wishlistAPI(route: "/v1/wishlist/\(w._id)", method: "DELETE", body: nil) { (status, error) in
                if let _ = status {
                    DispatchQueue.main.async {
                        self.appDelegate.user!.removeWishList(wishlist: self.wishlist!)
                        self.wishlist = nil
                        sender.setImage(UIImage(named: "bookmark"), for: .normal)
                        self.message.text = "Place removed from wishlist"
                        MDCSnackbarManager.show(self.message)
                    }
                } else if let e = error as? ResponseErrors {
                    DispatchQueue.main.async {
                        self.message.text = "Place could not be removed from wishlist"
                        MDCSnackbarManager.show(self.message)
                        print(e)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message.text = "Place could not be removed from wishlist"
                        MDCSnackbarManager.show(self.message)
//                        print("fatal error \(error)")
                    }
                }
            }
            return
        }
        
        let para:NSMutableDictionary = NSMutableDictionary()
        para.setValue(self.place_id, forKey: "place_id")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.setDateFormat()
                
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: para, options: JSONSerialization.WritingOptions())
                    
            wishlistAPI(route: "/v1/wishlist", method: "POST", body: jsonData) { (attraction, error) in
                
                if let wishlist = attraction {
                    DispatchQueue.main.async {
                        self.wishlist = wishlist
                        self.appDelegate.user!.wishlists?.append(wishlist)
                        sender.setImage(UIImage(named: "bookmark-done"), for: .normal)
                        self.message.text = "Place added to wishlist"
                        MDCSnackbarManager.show(self.message)
                    }
                } else if let e = error as? ResponseErrors {
                    print(e)
                    DispatchQueue.main.async {
                        self.message.text = "Place could not be added to wishlist"
                        MDCSnackbarManager.show(self.message)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("fatal error")
                        self.message.text = "Place could not be added to wishlist"
                        MDCSnackbarManager.show(self.message)
                    }
                }
            }
                    
        } catch {
            print("ERROR IN JSON PARSING \(error)")
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PlaceViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        
        cell.tintColor = .white
        cell.isSelectable = true
        cell.cornerRadius = 8
//        cell.setShadowElevation(ShadowElevation(rawValue: 6), for: .selected)
//        cell.setShadowColor(UIColor.black, for: .highlighted)
        
        cell.image.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        destVC.image = images[indexPath.row]
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}

class PhotoCell: MDCCardCollectionCell {
    
    let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 6
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        
        image.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
