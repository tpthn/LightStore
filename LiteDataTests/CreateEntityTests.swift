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

  func testCreateEntity() {
    let rootContext = LiteData.sharedInstance.rootContext
    let expectation = self.expectationWithDescription("Create Entity")
    
    guard let unitTestEntity = NSEntityDescription.entityForName("UnitTest", inManagedObjectContext: rootContext) else {
      XCTFail()
      return
    }
    
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = unitTestEntity
    var itemCount = 0
    
    // make sure we come from empty state
    rootContext.performBlock { [weak rootContext] in
      do {
        guard let fetchResults = try rootContext?.executeFetchRequest(fetchRequest) else { XCTFail(); return }
        itemCount = fetchResults.count
      }
      catch { XCTFail() }
    }
    
    // create the entity
    rootContext.createEntity(UnitTest.self) { createdEntity in
      createdEntity.name = "Create Entity"
    }
    
    // verify
    rootContext.performBlock { [weak rootContext] in
      do {
        guard let fetchResults = try rootContext?.executeFetchRequest(fetchRequest) else { XCTFail(); return }
        XCTAssertTrue(fetchResults.count == (itemCount + 1))
        expectation.fulfill()
      }
      catch { XCTFail() }
    }
    
    self.waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testCreateEntityAndWait() {
  
  }
}