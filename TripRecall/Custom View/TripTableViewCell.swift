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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellView.backgroundColor = UIColor(rgb: 0x0a173d)
        
        cellView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-50)
            make.height.equalTo(80)
            make.bottom.equalTo(-10)
        }
        
        tripNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(0)
        }
        
        tripDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tripNameLabel.snp.bottom).offset(10)
            make.right.equalTo(0)
            make.left.equalTo(15)
            make.bottom.equalTo(-10)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
