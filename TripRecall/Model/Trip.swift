//
//  Trip.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation
import GooglePlaces

class Trip: Codable {
    var _id: String?
    var trip_name: String
    var place_id: String {
        didSet(newTotalSteps) {
            print("About to set totalSteps to \(newTotalSteps)")
        }
    }
    var start_date: Date
    var end_date: Date
    var attractions: [Attraction]?
    var photos: [Photo]?
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
    
    func getDateAndDay() -> [(String, String)] {
        var startDate = self.start_date
        let calendar = Calendar.current

        var ranges = [(String, String)]()
        var idx = 1
        
        while startDate <= self.end_date {
            ranges.append(("Day \(idx)", startDate.toString()))
            
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            idx += 1
        }
        
        return ranges
    }
    
    func getAttractionByDate(date: String) -> [Attraction] {
        var att: [Attraction] = []

        for a in attractions! {
            if a.date.toString() == date {
                att.append(a)
            }
        }
        
        return att
    }
}
