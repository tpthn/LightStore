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
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    testEntity = nil
    fetchRequest = nil
  }
  
  func testWriteAsyncMainThread() {
    let expectation = self.expectationWithDescription("Write Async Main Thread")
    context = LiteData.sharedInstance.writeContext()
    
    context.createEntity(UnitTest.self, persisted: false) { createdEntity in
      XCTAssertFalse(NSThread.isMainThread(), "This should run on a different thread")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncMainThread() {
    context = LiteData.sharedInstance.writeContext()
    
    context.createEntityAndWait(UnitTest.self, persisted: false) { createdEntity in
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread")
    }
  }
  
  func testWriteAsyncBackground() {
    let expectation = self.expectationWithDescription("Write Async Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.createEntity(UnitTest.self, persisted: false) { createdEntity in
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
      
      self.context.createEntityAndWait(UnitTest.self, persisted: false) { createdEntity in
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
    
    context.createEntity(UnitTest.self, persisted: false) { createdEntity in
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread anyway")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testMainContextWriteSync() {
    context = LiteData.sharedInstance.mainContext
    
    context.createEntityAndWait(UnitTest.self, persisted: false) { createdEntity in
      XCTAssertTrue(NSThread.isMainThread(), "This should also run on main thread")
    }
  }
  
  // MARK: - Private
  var context: NSManagedObjectContext!
  
  lazy var testEntity: NSEntityDescription? = {
    let _testEntity = NSEntityDescription.entityForName("UnitTest", inManagedObjectContext: self.context)!
    return _testEntity
    }()
  
  lazy var fetchRequest: NSFetchRequest? = {
    let _fetchRequest = NSFetchRequest()
    _fetchRequest.entity = self.testEntity
    return _fetchRequest
    }()
  
  var fetchCount = 0
}
