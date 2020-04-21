//
//  Font.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation
import UIKit

struct Font {
    static let bold = { (size: CGFloat) in
        UIFont(name: "AvenirNext-Bold",  size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static let regular = { (size: CGFloat) in
        UIFont(name: "AvenirNext-Regular",  size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static let medium = { (size: CGFloat) in
        UIFont(name: "AvenirNext-Medium",  size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static let demibold = { (size: CGFloat) in
        UIFont(name: "AvenirNext-DemiBold",  size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
