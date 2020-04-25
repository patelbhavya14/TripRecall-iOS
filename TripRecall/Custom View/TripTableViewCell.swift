//
//  TripTableViewCell.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit

class TripTableViewCell: UITableViewCell {
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    
    var cardClicked: (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Tap gesture on card
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardClick(tapGesture:)))
        cellView.addGestureRecognizer(tap)
        cellView.isUserInteractionEnabled = true
        
        cardImage.translatesAutoresizingMaskIntoConstraints = false
        cardImage.contentMode = .scaleAspectFill
        cardImage.clipsToBounds = true
        
        cellView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(120)
            make.bottom.equalTo(-10)
        }
        
        cardImage.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(0)
            make.height.equalTo(120)
            make.width.equalTo(140)
        }
        
        tripNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(cardImage.snp.right).offset(10)
            make.right.equalTo(0)
        }
        
        tripDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tripNameLabel.snp.bottom).offset(10)
            make.right.equalTo(0)
            make.left.equalTo(cardImage.snp.right).offset(10)
            make.bottom.equalTo(-10)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions

    @objc func cardClick(tapGesture:UITapGestureRecognizer){
        cardClicked()
    }
}
