//
//  Trip.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation

class Trip: Codable {
    var _id: String?
    var trip_name: String
    var place_id: String
    var start_date: Date
    var end_date: Date
    var created_ts: Date?
    var updated_ts: Date?
    
    init(trip_name: String, place_id: String, start_date: Date, end_date: Date) {
        self.trip_name = trip_name
        self.place_id = place_id
        self.start_date = start_date
        self.end_date = end_date
    }
    
    func getTripDates() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        return "\(dateFormatter.string(from: self.start_date)) - \(dateFormatter.string(from: self.end_date))"
    }
}
