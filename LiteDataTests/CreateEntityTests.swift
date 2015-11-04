//
//  CreateEntityTests.swift
//  LiteData
//
//  Created by PC on 10/15/15.
//  Copyright © 2015 PC. All rights reserved.
//

import XCTest
import CoreData
@testable import LiteData

class CreateEntityTest: XCTestCase {
  
  let context = LiteData.sharedInstance.rootContext
  let fetchRequest = NSFetchRequest(entityName: "UnitTest")
  
  var fetchCount = 0
  
  override func setUp() {
    super.setUp()
    getCurrentCount()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testCreateEntity() {
    
    let expectation = self.expectationWithDescription("Create Entity Asynchronously")
    
    context.createEntity(UnitTest.self) { creatingEntity in
      creatingEntity.name = "Create Entity"
    }
    
    // verify
    self.verifyAditionalEntity {
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testCreateEntityAndWait() {
    
    context.createEntityAndWait(UnitTest.self) { creatingEntity in
      creatingEntity.name = "Create Entity And Wait"
    }
    
    verifyAdditonalEntityAndWait()
  }
  
  // MARK: Private
  
  func getCurrentCount() {
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        self.fetchCount = fetchResults.count
      }
      catch { XCTFail() }
    }
    
    print("\(self) Current Count: \(fetchCount)")
  }
  
  func verifyAditionalEntity(completion: ()->()) {
    context.performBlock { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertTrue(fetchResults.count == (self.fetchCount + 1))
        print("\(self) Verify Count: \(fetchResults.count)")
        completion()
      }
      catch { XCTFail() }
    }
  }
  
  func verifyAdditonalEntityAndWait() {
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertTrue(fetchResults.count == (self.fetchCount + 1))
        print("\(self) Verify Count: \(fetchResults.count)")
      }
      catch { XCTFail() }
    }
  }
}