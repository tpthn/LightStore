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
      createdEntity.name = "This run on a different thread"
      XCTAssertFalse(NSThread.isMainThread())
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncMainThread() {
    context = LiteData.sharedInstance.writeContext()
    
    context.createEntityAndWait(UnitTest.self, persisted: false) { createdEntity in
      createdEntity.name = "This run on main thread"
      XCTAssertTrue(NSThread.isMainThread())
    }
  }
  
  func testWriteAsyncBackground() {
    let expectation = self.expectationWithDescription("Write Async Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.createEntity(UnitTest.self, persisted: false) { createdEntity in
        createdEntity.name = "Spawn out different thread"
        XCTAssertFalse(NSThread.isMainThread())
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
        createdEntity.name = "Stay on same thread"
        XCTAssertFalse(NSThread.isMainThread())
        expectation.fulfill()
      }
    })
    
    waitForExpectationsWithTimeout(5, handler: nil)
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
