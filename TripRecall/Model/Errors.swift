//
//  Errors.swift
//  TripRecall
//
//  Created by Bhavya Patel on 19/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation

class ResponseErrors: Codable {
    var errors: [ResponseError] = []
}

class ResponseError: Codable {
    var msg: String
    
    init(msg: String) {
        self.msg = msg
    }
}
