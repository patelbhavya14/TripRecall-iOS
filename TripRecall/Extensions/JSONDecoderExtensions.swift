//
//  JSONDecoderExtensions.swift
//  TripRecall
//
//  Created by Bhavya Patel on 19/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation

extension JSONDecoder {
    func setDateFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        self.dateDecodingStrategy = .formatted(dateFormatter)
    }
}

extension JSONEncoder {
    func setDateFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.dateEncodingStrategy = .formatted(dateFormatter)
    }
}
