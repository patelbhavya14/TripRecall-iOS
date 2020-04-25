//
//  AttractionViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 21/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit
import MaterialComponents.MaterialCards
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialBottomSheet
import GooglePlaces

class AttractionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var attractionTable: UITableView!
    @IBOutlet weak var addButton: MDCButton!
    @IBOutlet weak var attractionView: UIView!
    var placesClient: GMSPlacesClient!
    
    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    var trip: Trip!
    var tabNo: Int!
    var tabs: [(String, String)] = []
    var attractions: [Attraction] = []
    
    var selectedDay = ""
    var addedAttraction: Attraction?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = trip.trip_name
        self.navigationController?.navigationBar.tintColor = UIColor.theme()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        placesClient = GMSPlacesClient.shared()
        
        tabs = trip.getDateAndDay()
        
        view.addSubview(collectionView)
        
        let containerScheme = MDCContainerScheme()
        addButton.applyOutlinedTheme(withScheme: containerScheme)
        addButton.setTitleColor(UIColor(rgb: 0x0a173d), for: .normal)
        addButton.setImageTintColor(UIColor(rgb: 0x0a173d), for: .normal)
        
        setupView()
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        attractions = trip.getAttractionByDate(date: tabs[0].1)
        
        attractionTable.separatorStyle = .none
        attractionTable.showsVerticalScrollIndicator = false
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let indexPath = IndexPath(item: 0, section: 0)
        selectedDay = tabs[indexPath.row].1
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if let attraction = addedAttraction {
            let newIndexPath = IndexPath(row: attractions.count, section: 0)
            trip.attractions?.append(attraction)
            attractions.append(attraction)
            attractionTable.insertRows(at: [newIndexPath], with: .automatic)
            addedAttraction = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - Private Methods
    
    private func setupView() {
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(80)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        
        attractionView.snp.makeConstraints { (make) in
            make.top.equalTo(addButton.snp.bottom).offset(10)
            make.bottom.equalTo(-30)
            make.left.equalTo(5)
            make.right.equalTo(-5)
        }
        
        attractionTable.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
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
    
    // MARK: - Table delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attractions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attractionCell", for: indexPath) as! AttractionTableViewCell
        let attraction = attractions[indexPath.row]
        
        cell.selectionStyle = .none
        
        
        // Set start time label
        if let start_time = attraction.start_time {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "h:mm a"
            
            let formattedString = dateFormatter.string(from: start_time)
            
            cell.startTimeLabel.text = formattedString
            cell.startTimeButton.setImage(UIImage(named: "start-time-done"), for: .normal)
        } else {
            cell.startTimeLabel.text = ""
            cell.startTimeButton.setImage(UIImage(named: "start-time"), for: .normal)
        }
        
        // Display place name and image
        self.getPlaceDetails(placeID: attraction.place_id) { (place, error) in
            if let place = place {
                cell.placeNameLabel.text = place.name
                
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
        
        // Set duration Label
        
        
        if let duration = attraction.duration {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .full

            let formattedString = formatter.string(from: TimeInterval(duration))!
            
            cell.durationLabel.text = formattedString
            cell.durationButton.setImage(UIImage(named: "duration-done"), for: .normal)
        } else {
            cell.durationLabel.text = ""
            cell.durationButton.setImage(UIImage(named: "duration"), for: .normal)
        }
            
        // Check whether attraction has a note or not
        if let _ = attraction.note {
            cell.noteButton.setImage(UIImage(named: "note-done"), for: .normal)
        }
        
        // Set transport label
        cell.transportButton.setImage(nil, for: .normal)
        cell.transportButton.setTitle("tap here to choose your transport", for: .normal)
        if let transport = attraction.transport {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .full

            let formattedString = formatter.string(from: TimeInterval(transport.time))!
            
            cell.transportButton.setTitle("take \(formattedString) to next place", for: .normal)
            cell.transportButton.setImage(UIImage(named: attraction.transport!.mode.rawValue), for: .normal)
            cell.transportButton.setImageTintColor(UIColor(rgb: 0x0a173d), for: .init())
        }
        
        cell.startTimeButtonPressed = {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
            
            viewController.attraction = attraction
            viewController.trip = self.trip
            viewController.indexRow = indexPath
            viewController.action = "start_time"
            viewController.tabNo = self.tabNo
            
            let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 250)
            // Present the bottom sheet
            self.present(bottomSheet, animated: true, completion: nil)
        }
        
        cell.durationButtonPressed = {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
            
            viewController.attraction = attraction
            viewController.trip = self.trip
            viewController.indexRow = indexPath
            viewController.action = "duration"
            viewController.tabNo = self.tabNo
            
            let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 250)
            // Present the bottom sheet
            self.present(bottomSheet, animated: true, completion: nil)
        }
        
        cell.noteButtonPressed = {
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
            destVC.attraction = attraction
            self.navigationController?.pushViewController(destVC, animated: true)

        }
        
        cell.transportButtonPressed = {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
            
            viewController.attraction = attraction
            viewController.trip = self.trip
            viewController.indexRow = indexPath
            viewController.action = "transport"
            viewController.tabNo = self.tabNo
            
            let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 350)
            // Present the bottom sheet
            self.present(bottomSheet, animated: true, completion: nil)
        }
        
        cell.cardClicked = {
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "PlaceViewController") as! PlaceViewController
            destVC.place_id = attraction.place_id
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 264
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonAction(_ sender: MDCButton) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        destVC.action = "AddAttraction"
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    

}

extension AttractionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.backgroundColor = UIColor(rgb: 0x0a173d)
        cell.tintColor = .white
        cell.isSelectable = true
        cell.cornerRadius = 8
        cell.setShadowElevation(ShadowElevation(rawValue: 6), for: .selected)
        cell.setShadowColor(UIColor.black, for: .highlighted)
        
        cell.day.text = tabs[indexPath.row].0
        cell.date.text = tabs[indexPath.row].1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDay = tabs[indexPath.row].1
        attractions = trip.getAttractionByDate(date: tabs[indexPath.row].1)
        attractionTable.reloadData()
    }
}

class CustomCell: MDCCardCollectionCell {
    
    let day: UILabel = {
        let l = UILabel()
        return l
    }()
    
    let date: UILabel = {
        let l = UILabel()
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(day)
        contentView.addSubview(date)
        
        day.textColor = .white
        date.textColor = .white
        day.font = UIFont.boldSystemFont(ofSize: 16.0)
        date.font = UIFont.systemFont(ofSize: 14.0)
        
//        contentView.snp.makeConstraints { (make) in
//            make.left.equalTo(5)
//            make.right.equalTo(-5)
//        }
        
        day.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.centerX.equalToSuperview()
        }
        
        date.snp.makeConstraints { (make) in
            make.top.equalTo(day.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
