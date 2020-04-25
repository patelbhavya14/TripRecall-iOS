//
//  WishlistTableViewCell.swift
//  TripRecall
//
//  Created by Bhavya Patel on 24/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit

class WishlistTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    var cardClicked: (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Tap gesture on card
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardClick1(tapGesture:)))
        cellView.addGestureRecognizer(tap)
        cellView.isUserInteractionEnabled = true
        
        cardImage.translatesAutoresizingMaskIntoConstraints = false
        cardImage.contentMode = .scaleAspectFill
        cardImage.clipsToBounds = true
        
        cellView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(120)
            make.bottom.equalTo(-10)
        }
        
        cardImage.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(0)
            make.height.equalTo(120)
            make.width.equalTo(140)
        }
        
        placeNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(cardImage.snp.right).offset(10)
            make.right.equalTo(0)
            make.centerY.equalToSuperview()
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions

    @objc func cardClick1(tapGesture:UITapGestureRecognizer){
        cardClicked()
    }
    
}
