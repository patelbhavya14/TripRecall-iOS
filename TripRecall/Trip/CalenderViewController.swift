//
//  CalenderViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 23/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import FSCalendar
import SnapKit

class CalenderViewController: UIViewController, FSCalendarDelegate {
    @IBOutlet weak var calenderView: FSCalendar!
    var currentDate: Date?
    var textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calenderView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(5)
            make.right.equalTo(-15)
            make.height.equalTo(300)
        }
        calenderView.select(currentDate, scrollToDate: true)
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Calender Date Source
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        DispatchQueue.main.async {
            self.textfield.text = date.toString()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
