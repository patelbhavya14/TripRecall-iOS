//
//  AttractionTableViewCell.swift
//  TripRecall
//
//  Created by Bhavya Patel on 21/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit
import MaterialComponents.MaterialButtons_Theming

class AttractionTableViewCell: UITableViewCell {
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var placeCard: UIView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var transportButton: MDCButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    
    var startTimeButtonPressed: (() -> ()) = {}
    var durationButtonPressed: (() -> ()) = {}
    var noteButtonPressed: (() -> ()) = {}
    var transportButtonPressed: (() -> ()) = {}
    var cardClicked: (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Tap gesture on card
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardClick(tapGesture:)))
        placeCard.addGestureRecognizer(tap)
        placeCard.isUserInteractionEnabled = true
        
        cardImage.translatesAutoresizingMaskIntoConstraints = false
        cardImage.contentMode = .scaleAspectFill
        cardImage.clipsToBounds = true
        
        let containerScheme = MDCContainerScheme()
        transportButton.applyOutlinedTheme(withScheme: containerScheme)
        transportButton.isUppercaseTitle = false
        transportButton.setTitleColor(UIColor(rgb: 0x0a173d), for: .normal)
        transportButton.setImageTintColor(UIColor(rgb: 0x0a173d), for: .normal)
        
        startTimeLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        durationLabel.textColor = UIColor(rgb: 0x0a173d)
        
        cellView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        startTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
        }
        
        placeCard.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(startTimeLabel.snp.bottom).offset(10)
            make.height.equalTo(120)
        }
        
        cardImage.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(0)
            make.height.equalTo(120)
            make.width.equalTo(140)
        }
        
        placeNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cardImage.snp.right).offset(10)
            make.height.equalTo(80)
            make.top.equalTo(10)
            make.right.equalTo(-5)
        }
        
        durationLabel.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(-10)
        }
        
        noteButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(placeCard.snp.bottom).offset(10)
        }
        
        durationButton.snp.makeConstraints { (make) in
            make.right.equalTo(-70)
            make.top.equalTo(placeCard.snp.bottom).offset(10)
        }
        
        startTimeButton.snp.makeConstraints { (make) in
            make.right.equalTo(-130)
            make.top.equalTo(placeCard.snp.bottom).offset(10)
        }
        
        transportButton.snp.makeConstraints { (make) in
            make.top.equalTo(noteButton.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(50)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    @IBAction func startTimeButtonAction(_ sender: UIButton) {
        startTimeButtonPressed()
    }
    
    @IBAction func durationButtonAction(_ sender: UIButton) {
        durationButtonPressed()
    }
    
    @IBAction func noteButtonAction(_ sender: Any) {
        noteButtonPressed()
    }
    
    @IBAction func transportButtonAction(_ sender: MDCButton) {
        transportButtonPressed()
    }
    
    @objc func cardClick(tapGesture:UITapGestureRecognizer){
        cardClicked()
    }
    
    
}
