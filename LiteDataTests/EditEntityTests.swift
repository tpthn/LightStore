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
  var unitTest: UnitTest?

  override func setUp() {
    super.setUp()
    
    // make sure we come from empty state
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
  
  override func tearDown() {
    super.tearDown()
  }

  func testEditEntity() {
    
    let expectation = self.expectationWithDescription("Edit Entity Asynchronously")
    
    guard let _unitTest = unitTest else { XCTFail(); return }
    context.editEntity(_unitTest) { editingEntity in
      editingEntity.name = "Edit Entity Asynchronously"
    }
    
    // verify
    context.performBlock { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Edit Entity Asynchronously")
        expectation.fulfill()
      }
      catch { XCTFail() }
    }
    
    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
  func testEditEntityAndWait() {
    guard let _unitTest = unitTest else { XCTFail(); return }
    
    context.editEntityAndWait(_unitTest) { editingEntity in
      editingEntity.name = "Edit Entity Synchronously"
    }
    
    // verify
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Edit Entity Synchronously")
      }
      catch { XCTFail() }
    }
  }
  
  // MARK: - Private
  let context = LiteData.sharedInstance.rootContext
  
  lazy var testEntity: NSEntityDescription = {
    let _testEntity = NSEntityDescription.entityForName("UnitTest", inManagedObjectContext: self.context)!
    return _testEntity
    }()
  
  lazy var fetchRequest: NSFetchRequest = {
    let _fetchRequest = NSFetchRequest()
    _fetchRequest.entity = self.testEntity
    return _fetchRequest
    }()
}
