//
//  SearchTableViewCell.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        placeNameLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(15)
            make.right.equalTo(0)
        }
        
        placeLocationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(placeNameLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
