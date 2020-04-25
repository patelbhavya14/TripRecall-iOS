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
import MaterialComponents.MaterialSnackbar

class AddTripViewController: UIViewController, UITextFieldDelegate {
    var place: Place!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var tripNameText: MDCFilledTextField!
    @IBOutlet weak var startDateText: MDCFilledTextField!
    @IBOutlet weak var endDateText: MDCFilledTextField!
    @IBOutlet weak var addTripView: UIView!
    @IBOutlet weak var addTripButton: MDCButton!
    @IBOutlet weak var backBtn: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // UI Components
    let message = MDCSnackbarMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let containerScheme = MDCContainerScheme()
        addTripButton.applyContainedTheme(withScheme: containerScheme)
        addTripButton.backgroundColor = UIColor.theme()
        
        setupView()
        
        placeNameLabel.text = place.place_name
        imageView.image = place.place_image!
        
        // Setting textfield labels
        tripNameText.label.text = "Trip Name"
        
//        let v = UIView()
//        let im = UIImage(named: "car")
//        let im1 = UIImageView(image: im!)
//        v.addSubview(im1)
//        tripNameText.leadingView = v
        
        startDateText.label.text = "Start Date"
        startDateText.text = ""
        startDateText.delegate = self
        
        endDateText.label.text = "End Date"
        endDateText.text = ""
        endDateText.delegate = self
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Textfield delegate method
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.endEditing(true)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CalenderViewController") as! CalenderViewController
        
        let df = DateFormatter()
        df.dateFormat = "d MMM y"
        viewController.currentDate = df.date(from: textField.text ?? "")
        viewController.textfield = textField
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
        // Present the bottom sheet
        self.present(bottomSheet, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods

    private func setupView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
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
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-10)
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
            make.height.equalTo(50)
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
        let trip = Trip(trip_name: tripNameText.text ?? "", place_id: place.place_id, start_date: startDateText.text?.toAttractionDate() ?? Date(), end_date: endDateText.text?.toAttractionDate() ?? Date())

        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.setDateFormat()
        
        do {
            let jsonData = try jsonEncoder.encode(trip)
            
            addTrip(route: "/v1/trip", body: jsonData) { (status, error) in
                if let _ = status {
                    DispatchQueue.main.async {
                        self.message.text = "Trip created successfully"
                        MDCSnackbarManager.show(self.message)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                } else if let e = error as? ResponseErrors {
                    DispatchQueue.main.async {
                        self.message.text = e.errors[0].msg
                        MDCSnackbarManager.show(self.message)
                    }
                    print(e)
                } else {
                    DispatchQueue.main.async {
                        self.message.text = "Trip could not be added"
                        MDCSnackbarManager.show(self.message)
                    }
                    print("fatal error")
                }
            }
            
        }
        catch {
            print("ERROR IN JSON PARSING \(error)")
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
