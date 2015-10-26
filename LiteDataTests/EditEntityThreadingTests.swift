//
//  EditEntityThreadingTests.swift
//  LiteData
//
//  Created by PC on 10/26/15.
//  Copyright © 2015 PC. All rights reserved.
//

import XCTest
import CoreData
@testable import LiteData

class EditEntityThreadingTests: XCTestCase {
  
  var unitTest: UnitTest?
  
  override func setUp() {
    super.setUp()
    
    // get a sample entity for editing
    let rootContext = LiteData.sharedInstance.rootContext
  
    rootContext.performBlockAndWait { [unowned self, unowned rootContext] in
      do {
        let fetchRequest = NSFetchRequest(entityName: "UnitTest")
        let fetchResults = try rootContext.executeFetchRequest(fetchRequest)
        self.unitTest = (fetchResults as? Array)?.first
        self.unitTest?.name = "Initial Name"
        rootContext.safeSave()
      }
      catch { XCTFail() }
    }
  }
  
  func testWriteAsyncMainThread() {
    let expectation = self.expectationWithDescription("Write Async Main Thread")
    context = LiteData.sharedInstance.writeContext()
    
    context.editEntity(unitTest!, persisted: false) { _ in
      XCTAssertFalse(NSThread.isMainThread(), "This should run on a different thread")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncMainThread() {
    context = LiteData.sharedInstance.writeContext()
    
    context.editEntityAndWait(unitTest!, persisted: false) { _ in
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread")
    }
  }
  
  func testWriteAsyncBackground() {
    let expectation = self.expectationWithDescription("Write Async Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.editEntity(self.unitTest!, persisted: false) { _ in
        XCTAssertFalse(NSThread.isMainThread(), "This should spawn out different thread")
        expectation.fulfill()
      }
    })
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncBackground() {
    let expectation = self.expectationWithDescription("Write Async Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.editEntityAndWait(self.unitTest!, persisted: false) { _ in
        XCTAssertFalse(NSThread.isMainThread(), "This should stay on same background thread")
        expectation.fulfill()
      }
    })
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  // MARK: - Abnormal Behavior - Main context should be for read-only
  
  func testMainContextWriteAsync() {
    let expectation = self.expectationWithDescription("Main Context Write Async")
    context = LiteData.sharedInstance.mainContext
    
    context.editEntity(self.unitTest!, persisted: false) { _ in
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread anyway")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testMainContextWriteSync() {
    context = LiteData.sharedInstance.mainContext
    
    context.editEntityAndWait(self.unitTest!, persisted: false) { _ in
      XCTAssertTrue(NSThread.isMainThread(), "This should also run on main thread")
    }
  }
  
  // MARK: - Private
  var context: NSManagedObjectContext!
}
