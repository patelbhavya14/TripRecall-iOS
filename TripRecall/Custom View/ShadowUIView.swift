//
//  ShadowUIView.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MDCShadowLayer

class ShadowedView: UIView {

  override class var layerClass: AnyClass {
    return MDCShadowLayer.self
  }

  var shadowLayer: MDCShadowLayer {
    return self.layer as! MDCShadowLayer
  }

  func setDefaultElevation() {
    self.shadowLayer.elevation = .cardResting
  }

}
