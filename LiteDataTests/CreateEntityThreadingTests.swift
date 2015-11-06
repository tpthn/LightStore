//
//  CreateEntityThreadingTests.swift
//  LiteData
//
//  Created by PC on 10/15/15.
//  Copyright © 2015 PC. All rights reserved.
//

import XCTest
import CoreData
@testable import LiteData

class CreateEntityThreadingTests: XCTestCase {
  
  let fetchRequest = NSFetchRequest(entityName: "UnitTest")
  
  var context: NSManagedObjectContext!
  var fetchCount = 0
  
  override func setUp() {
    super.setUp()
    getCurrentCount()
  }

  override func tearDown() {
    super.tearDown()
  }
  
  func testWriteAsyncMainThread() {
    let expectation = self.expectationWithDescription("Write Async Main Thread")
    context = LiteData.sharedInstance.writeContext()
    
    context.createEntity(UnitTest.self) { creatingEntity in
      XCTAssertFalse(NSThread.isMainThread(), "This should run on a different thread - non blocking")
      creatingEntity.name = "write async on main thread"
    }
    
    // verification happen on different MOC (root MOC) so we need a delay here
    TestUtility.delay(0.5) { [unowned self] in
      self.verifyAdditonalEntityAndWait()
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncMainThread() {
    context = LiteData.sharedInstance.writeContext()
    
    context.createEntityAndWait(UnitTest.self) { creatingEntity in
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread - blocking")
      creatingEntity.name = "write sync on main thread"
    }
    
    verifyAdditonalEntityAndWait()
  }
  
  func testWriteAsyncBackground() {
    let expectation = self.expectationWithDescription("Write Async Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.createEntity(UnitTest.self) { creatingEntity in
        XCTAssertFalse(NSThread.isMainThread(), "This should spawn out different thread")
        creatingEntity.name = "write async on background thread"
      }
    })
    
    // verification happen on different MOC (root MOC) so we need a delay here
    TestUtility.delay(0.5) { [unowned self] in
      self.verifyAdditonalEntityAndWait()
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncBackground() {
    let expectation = self.expectationWithDescription("Write Async Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.createEntityAndWait(UnitTest.self) { creatingEntity in
        XCTAssertFalse(NSThread.isMainThread(), "This should stay on same background thread")
        creatingEntity.name = "Write sync on background thread"
      }
      
      self.verifyAdditonalEntityAndWait()
      expectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  // MARK: - Abnormal Behavior - Main context should be for read-only
  
  func testMainContextWriteAsync() {
    let expectation = self.expectationWithDescription("Main Context Write Async")
    context = LiteData.sharedInstance.mainContext
    
    context.createEntity(UnitTest.self) { creatingEntity in
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread anyway")
      creatingEntity.name = "Write Async to Main MOC"
    }
    
    // verification happen on different MOC (root MOC) so we need a delay here
    TestUtility.delay(0.5) { [unowned self] in
      self.verifyAdditonalEntityAndWait()
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testMainContextWriteSync() {
    context = LiteData.sharedInstance.mainContext
    
    context.createEntityAndWait(UnitTest.self) { creatingEntity in
      XCTAssertTrue(NSThread.isMainThread(), "This should also run on main thread")
      creatingEntity.name = "Write Sync to Main MOC"
    }
    
    self.verifyAdditonalEntityAndWait()
  }
  
  // MARK: Private
  
  func getCurrentCount() {
    context = LiteData.sharedInstance.rootContext
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        self.fetchCount = fetchResults.count
      }
      catch { XCTFail() }
    }
    
    print("\(self) Current Count: \(fetchCount)")
  }
  
  func verifyAdditonalEntityAndWait() {
    context = LiteData.sharedInstance.rootContext
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
