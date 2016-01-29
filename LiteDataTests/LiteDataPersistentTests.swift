//
//  LiteDataPersistentTests.swift
//  LiteData
//
//  Created by PC on 1/29/16.
//  Copyright © 2016 PC. All rights reserved.
//

import XCTest
@testable import LiteData

class LiteDataPersistentTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testAddDataEntity() {
    let expectation = self.expectationWithDescription("Write Async Main Thread")
    
    LiteData.entity(UnitTest.self).add({ creatingEntity in
      creatingEntity.name = "Add Entity Async Test"
    }).persist { persistedEntity, error -> () in
      XCTAssertNotNil(persistedEntity!)
      XCTAssertEqual(persistedEntity?.name, "Add Entity Async Test")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(30, handler:nil)
  }
}
