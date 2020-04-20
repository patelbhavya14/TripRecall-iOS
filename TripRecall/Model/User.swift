//
//  User.swift
//  TripRecall
//
//  Created by Bhavya Patel on 19/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation

class User: Codable {
    var _id: String?
    var email: String
    var password: String?
    var username: String?
    var created_at: Date?
    var updated_at: Date?
    
    init(email: String) {
        self.email = email
    }
}
