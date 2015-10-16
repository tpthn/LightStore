//
//  ClassDescriptorTests.swift
//  LiteData
//
//  Created by PC on 10/15/15.
//  Copyright © 2015 PC. All rights reserved.
//

import XCTest
@testable import LiteData

class ClassDescriptorTests: XCTestCase {
  
  func testClassName() {
    
    // AnyObject
    var className = ClassDescriptor<NSString>().className
    XCTAssertEqual(className, "NSString")
    
    // Any
    className = ClassDescriptor<String>().className
    XCTAssertEqual(className, "String")
    
    className = ClassDescriptor<Int>().className
    XCTAssertEqual(className, "Int")
    
    // Objc Primitive
    className = ClassDescriptor<CGFloat>().className
    XCTAssertEqual(className, "CGFloat")
    
  }
}
