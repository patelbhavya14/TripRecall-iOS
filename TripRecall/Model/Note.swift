//
//  Note.swift
//  TripRecall
//
//  Created by Bhavya Patel on 22/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation

class Note: Codable {
    var _id: String?
    var detail: String
    
    init(detail: String) {
        self.detail = detail
    }
}
