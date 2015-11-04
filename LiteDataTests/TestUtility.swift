//
//  TestUtility.swift
//  LiteData
//
//  Created by PC on 10/28/15.
//  Copyright © 2015 PC. All rights reserved.
//

import Foundation

class TestUtility {
  // MARK: http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
  class func delay(delay:Double, closure:()->()) {
    dispatch_after(
      dispatch_time(
        DISPATCH_TIME_NOW,
        Int64(delay * Double(NSEC_PER_SEC))
      ),
      dispatch_get_main_queue(), closure)
  }
}
