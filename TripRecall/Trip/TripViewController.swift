//
//  TripViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 21/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit
import MaterialComponents.MDCButton_MaterialTheming

class TripViewController: UIViewController {
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var saveButton: MDCButton!
    @IBOutlet weak var cancelButton: MDCButton!
    @IBOutlet weak var transportView: UIStackView!
    @IBOutlet var transportButtons: [UIButton]!
    
    var trip: Trip!
    var attraction: Attraction!
    var indexRow: IndexPath!
    var action: String!
    var selectedButton: Mode?
    var tabNo: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(rgb: 0x0a173d)
        durationPicker.setValue(UIColor.white, forKeyPath: "textColor")
        durationPicker.setValue(false, forKey: "highlightsToday")
        durationPicker.subviews[0].subviews[1].backgroundColor = UIColor.white
        durationPicker.subviews[0].subviews[2].backgroundColor = UIColor.white
        
        let containerScheme = MDCContainerScheme()
        saveButton.applyTextTheme(withScheme: containerScheme)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        
        cancelButton.applyTextTheme(withScheme: containerScheme)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        
        print(indexRow.row)
        
        transportView.isHidden = true
        if action == "duration" {
            durationPicker.datePickerMode = .countDownTimer
        }  else if action == "start_time" {
            durationPicker.datePickerMode = .time
        } else {
            selectedButton = Mode.car
            transportButtons[0].setImage(UIImage(named: "\(selectedButton!.rawValue)-select"), for: .normal)
            durationPicker.datePickerMode = .countDownTimer
            transportView.isHidden = false
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
        }
        
        saveButton.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.right.equalTo(-10)
        }
        
        durationPicker.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(saveButton.snp.bottom).offset(10)
            make.height.equalTo(200)
        }
        
        transportView.snp.makeConstraints { (make) in
            make.top.equalTo(durationPicker.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(50)
        }
        
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private methods
    
    private func updateAttraction(route: String, body: Data, completion: @escaping (Attraction?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: route, method: "PUT", access: "public", body: body) { (result, error) in
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
    
    // MARK: - Actions
    
    @IBAction func saveButtonAction(_ sender: Any) {

        print(Int(durationPicker.countDownDuration))
        let jsonEncoder = JSONEncoder()
        
        if action == "duration" {
            attraction.duration = Int(durationPicker.countDownDuration)
            jsonEncoder.setDateFormat()
        } else if action == "start_time" {
            attraction.start_time = durationPicker.date
            jsonEncoder.setEpochDateFormat()
        } else {
            let transport = Transport(mode: selectedButton ?? Mode.car, time: Int(durationPicker.countDownDuration))
            attraction.transport = transport
        }
        
        
        
        do {
            let jsonData = try jsonEncoder.encode(attraction)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            
            updateAttraction(route: "/v1/trip/\(trip._id!)/attraction/\(attraction._id!)", body: jsonData) { (attraction, error) in
                
                if let attraction = attraction {
                    DispatchQueue.main.async {
                        if let tabBar = self.presentingViewController as? UITabBarController {
                            let homeNavigationViewController = tabBar.viewControllers![self.tabNo] as? UINavigationController
                            let attractionViewController = homeNavigationViewController?.viewControllers[1] as! AttractionViewController
                            attractionViewController.attractions[self.indexRow.row] = attraction
                            attractionViewController.attractionTable.reloadRows(at: [self.indexRow], with: .none)
                        }
                        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func transpostButtonAction(_ sender: UIButton) {
        for (idx, btn) in transportButtons.enumerated() {
            if sender == btn {
                selectedButton = Mode.allValues[idx]
                sender.setImage(UIImage(named: "\(selectedButton!.rawValue)-select"), for: .normal)
            } else {
                btn.setImage(UIImage(named: Mode.allValues[idx].rawValue), for: .normal)
            }
        }
    }
    
    
}
