//
//  DeleteEntityThreadingTests.swift
//  LiteData
//
//  Created by PC on 11/6/15.
//  Copyright © 2015 PC. All rights reserved.
//

import XCTest
import CoreData
@testable import LiteData

class DeleteEntityThreadingTests: XCTestCase {
  
  var unitTest: UnitTest?
  var context: NSManagedObjectContext!
  
  lazy var fetchRequest: NSFetchRequest = {
    let _fetchRequest = NSFetchRequest(entityName: "UnitTest")
    let predicate = NSPredicate(format: "name == %@", "To be deleted")
    _fetchRequest.predicate = predicate;
    return _fetchRequest
  }()
  
  override func setUp() {
    super.setUp()
    
    // make sure we have entity to delete
    context = LiteData.sharedInstance.rootContext
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
  
  func testWriteAsyncMainThread() {
    
    let expectation = self.expectationWithDescription("Write Async Main Thread")
    
    verifyEntityExistAndWait()
    
    context = LiteData.sharedInstance.writeContext()
    context.deleteEntity(unitTest!)
    
    // verification happen on different MOC (root MOC) so we need a delay here
    TestUtility.delay(0.5) {
      self.verifyEntityDeletedAndWait()
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  // MARK: Private
  
  func verifyEntityExistAndWait() {
    
    context = LiteData.sharedInstance.rootContext
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertEqual(fetchResults.count, 1)
      }
      catch { XCTFail() }
    }
  }
  
  func verifyEntityDeletedAndWait() {
    
    context = LiteData.sharedInstance.rootContext
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        XCTAssertEqual(fetchResults.count, 0)
      }
      catch { XCTFail() }
    }
  }
}
