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
    var trips: [Trip]?
    var wishlists: [Wishlist]?
    
    init(email: String) {
        self.email = email
        self.trips = []
    }
    
    func getPastTrips() -> [Trip] {
        var past: [Trip] = []
        for t in trips! {
            if t.end_date < Date() {
                past.append(t)
            }
        }
        
        return past
    }
    
    func getOngoingTrips() -> [Trip] {
        var ongoing: [Trip] = []
        for t in trips! {
            let d = Date()
            if t.start_date <= d && t.end_date >= d {
                ongoing.append(t)
            }
        }
        
        return ongoing
    }
    
    func getFutureTrips() -> [Trip] {
        var future: [Trip] = []
        for t in trips! {
            if t.start_date > Date() {
                future.append(t)
            }
        }
        
        return future
    }
    
    func isPlaceInWishlist(place_id: String) -> Wishlist? {
        for w in wishlists!{
            if w.place_id == place_id {
                return w
            }
        }
        return nil
    }
    
    func removeWishList(wishlist: Wishlist) {
        wishlists = wishlists?.filter { $0 !== wishlist }
    }
    
    func removeTrip(trip: Trip) {
        trips = trips?.filter { $0 !== trip }
    }
}
