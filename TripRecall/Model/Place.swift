//
//  Place.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation
import UIKit

class Place {
    var place_id: String
    var place_name: String
    var place_location: String?
    var place_image: UIImage?
    
    init(place_id: String, place_name: String, place_location: String?) {
        self.place_id = place_id
        self.place_name = place_name
        self.place_location = place_location
    }
}
