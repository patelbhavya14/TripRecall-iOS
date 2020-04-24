//
//  Attraction.swift
//  TripRecall
//
//  Created by Bhavya Patel on 21/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation

class Attraction: Codable {
    var _id: String?
    var place_id: String = ""
    var date: Date
    var start_time: Date?
    var duration: Int?
    var note: Note?
    var transport: Transport?
    var created_at: Date?
    var updated_at: Date?
    
    init(place_id: String, date: Date) {
        self.place_id = place_id
        self.date = date
    }
}

class Transport: Codable {
    var mode: Mode
    var time: Int
    
    init(mode: Mode, time: Int) {
        self.mode = mode
        self.time = time
    }
}

enum Mode: String, Codable {
    case car
    case transport = "public-transit"
    case walk
    case plane
    
    static let allValues = [car, transport, walk, plane]
}
