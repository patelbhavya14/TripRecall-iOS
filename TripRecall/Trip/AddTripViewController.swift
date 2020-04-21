//
//  AddTripViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTabs
import SnapKit
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MDCFilledTextField
import MaterialComponents.MDCOutlinedTextField

class AddTripViewController: UIViewController {
    var place: Place!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
//    @IBOutlet weak var tripNameText: MDCFilledTextField!
    @IBOutlet weak var tripNameText: MDCOutlinedTextField!
    @IBOutlet weak var startDateText: MDCFilledTextField!
    @IBOutlet weak var endDateText: MDCFilledTextField!
    @IBOutlet weak var addTripView: UIView!
    @IBOutlet weak var addTripButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let containerScheme = MDCContainerScheme()
//        addTripButton.applyContainedTheme(withScheme: containerScheme)
//        addTripButton.backgroundColor = UIColor(rgb: 0x0a173d)
        
        placeNameLabel.text = place.place_name
        imageView.image = place.place_image!
        
        // Setting textfield labels
        tripNameText.label.text = "Trip Name"
        tripNameText.text = "Summer 2021 Holidays"
        
        startDateText.label.text = "Start Date"
        startDateText.text = "2021-08-14"
        
        endDateText.label.text = "End Date"
        endDateText.text = "2021-09-29"
        
//        setupView()
        // Do any additional setup after loading the view.
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
        
        descLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(topView)
            make.left.equalTo(15)
            make.right.equalTo(0)
        }
        
        placeNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(descLabel.snp.bottom).offset(5)
            make.left.equalTo(15)
            make.right.equalTo(0)
        }
        
        addTripView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        
        tripNameText.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
        }
        
        startDateText.snp.makeConstraints { (make) in
            make.top.equalTo(tripNameText.snp.bottom).offset(10)
            make.left.right.equalTo(0)
        }
        
        endDateText.snp.makeConstraints { (make) in
            make.top.equalTo(startDateText.snp.bottom).offset(10)
            make.left.right.equalTo(0)
        }
        
        addTripButton.snp.makeConstraints { (make) in
            make.top.equalTo(endDateText.snp.bottom).offset(10)
            make.left.right.equalTo(0)
        }
    }
    
    private func addTrip(route: String, body: Data, completion: @escaping (String?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: route, method: "POST", access: "public", body: body) { (result, error) in
            if let result = result {
                do {
                    //create json object from data
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.setDateFormat()
                        
                        let trip = try jsonDecoder.decode(Trip.self, from: result)
                        self.appDelegate.user?.trips?.append(trip)
                        completion("success", nil)
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
        let trip = Trip(trip_name: tripNameText.text ?? "", place_id: place.place_id, start_date: startDateText.text?.toDate() ?? Date(), end_date: endDateText.text?.toDate() ?? Date())

        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.setDateFormat()
        
        do {
            let jsonData = try jsonEncoder.encode(trip)
            
            addTrip(route: "/v1/trip", body: jsonData) { (status, error) in
                if let _ = status {
//                    let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController") as! ThirdViewController
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                } else if let e = error as? ResponseErrors {
                    print(e)
                } else {
                    print("fatal error")
                }
            }
            
        }
        catch {
            print("ERROR IN JSON PARSING \(error)")
        }
        
    }
    
}
