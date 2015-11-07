//
//  EditEntityTests.swift
//  LiteData
//
//  Created by PC on 10/22/15.
//  Copyright © 2015 PC. All rights reserved.
//

import XCTest
import CoreData
@testable import LiteData

class EditEntityTests: XCTestCase {
  
  let context = LiteData.sharedInstance.rootContext
  let fetchRequest = NSFetchRequest(entityName: "UnitTest")
  
  var unitTest: UnitTest?
  
  override func setUp() {
    super.setUp()
    
    // make sure the original name is different
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        self.unitTest = (fetchResults as? Array)?.first
        self.unitTest?.name = "Initial Name"
        self.context.safeSave()
      }
      catch { XCTFail() }
    }
  }

  func testEditEntity() {
    
    let expectation = self.expectationWithDescription("Edit Entity Asynchronously")
    
    guard let _unitTest = unitTest else { XCTFail(); return }
    context.editEntity(_unitTest) { editingEntity in
      editingEntity.name = "Edit Entity Asynchronously"
    }
    
    verifyEditedEntity {
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testEditEntityAndWait() {
    guard let _unitTest = unitTest else { XCTFail(); return }
    
    context.editEntityAndWait(_unitTest) { editingEntity in
      editingEntity.name = "Edit Entity Synchronously"
    }
    
    verifyEditedEntityAndWait()
  }
  
  func verifyEditedEntity(completion: ()->()) {
    context.performBlock { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Edit Entity Asynchronously")
        completion()
      }
      catch { XCTFail() }
    }
  }
  
  func verifyEditedEntityAndWait() {
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Edit Entity Synchronously")
      }
      catch { XCTFail() }
    }
  }
}
