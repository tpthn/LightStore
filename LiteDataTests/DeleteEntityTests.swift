//
//  DeleteEntityTests.swift
//  LiteData
//
//  Created by PC on 10/28/15.
//  Copyright © 2015 PC. All rights reserved.
//

import XCTest
import CoreData
@testable import LiteData

class DeleteEntityTests: XCTestCase {

  let context = LiteData.sharedInstance.rootContext
  
  var unitTest: UnitTest?
  
  lazy var fetchRequest: NSFetchRequest = {
    let _fetchRequest = NSFetchRequest(entityName: "UnitTest")
    let predicate = NSPredicate(format: "name == %@", "To be deleted")
    _fetchRequest.predicate = predicate;
    return _fetchRequest
    }()
  
  override func setUp() {
    super.setUp()
    
    // make sure we have entity to delete
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchRequest = NSFetchRequest(entityName: "UnitTest")
        let fetchResults = try self.context.executeFetchRequest(fetchRequest)
        self.unitTest = (fetchResults as? Array)?.first
        self.unitTest?.name = "To be deleted"
        self.context.safeSave()
      }
      catch { XCTFail() }
    }
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testDeleteEntity() {
    let expectation = self.expectationWithDescription("Delete Entity Asynchronously")
    
    verifyEntityExist()
    
    // delete
    guard let _unitTest = unitTest else { XCTFail(); return }
    context.deleteEntity(_unitTest)
    
    verifyEntityDeletedWithCompletion {
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testDeleteEntityAndWait() {
    
    verifyEntityExistAndWait()
    
    // delete
    guard let _unitTest = unitTest else { XCTFail(); return }
    context.deleteEntity(_unitTest)
    
    verifyEntityDeletedAndWait()
  }
  
  func verifyEntityExistAndWait() {
    
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertEqual(fetchResults.count, 1)
      }
      catch { XCTFail() }
    }
  }
  
  func verifyEntityDeletedAndWait() {
    
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertEqual(fetchResults.count, 0)
      }
      catch { XCTFail() }
    }
  }
  
  func verifyEntityExist() {
    context.performBlock { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertEqual(fetchResults.count, 1)
      }
      catch { XCTFail() }
    }
  }
  
  func verifyEntityDeletedWithCompletion(completion: () -> ()) {
    context.performBlock { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertEqual(fetchResults.count, 0)
        completion()
      }
      catch { XCTFail() }
    }
  }
}
