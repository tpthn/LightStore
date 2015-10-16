//
//  ClassDescriptor.swift
//  LiteData
//
//  Created by PC on 10/15/15.
//  Copyright © 2015 PC. All rights reserved.
//

import Foundation

struct ClassDescriptor<T> {
  
  var className: String {
    let fullName = "\(T.self)"
    let segments = fullName.componentsSeparatedByString(".")
    return segments[segments.count - 1]
  }
  
}