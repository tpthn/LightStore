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
  
  let fetchRequest = NSFetchRequest(entityName: "UnitTest")
  
  var unitTest: UnitTest?
  var context: NSManagedObjectContext!
  
  override func setUp() {
    super.setUp()
    
    /* 
     * get a sample entity from root context
     * Then we edit it using background context
     */
    let rootContext = LiteData.sharedInstance.rootContext
  
    rootContext.performBlockAndWait { [unowned self, unowned rootContext] in
      do {
        let fetchResults = try rootContext.executeFetchRequest(self.fetchRequest)
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
    
    context.editEntity(unitTest!) { editingEntity in
      editingEntity.name = "Write Async Main Thread"
      XCTAssertFalse(NSThread.isMainThread(), "This should run on a different thread")
    }
    
    // verify
    context.performBlock { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Write Async Main Thread")
        expectation.fulfill()
      }
      catch { XCTFail() }
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncMainThread() {
    context = LiteData.sharedInstance.writeContext()
    
    context.editEntityAndWait(unitTest!) { editingEntity in
      editingEntity.name = "Write Sync Main Thread"
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread")
    }
    
    // verify
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Write Sync Main Thread")
      }
      catch { XCTFail() }
    }
  }
  
  func testWriteAsyncBackground() {
    let expectation = self.expectationWithDescription("Write Async Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.editEntity(self.unitTest!) { editingEntity in
        editingEntity.name = "Write Async background"
        XCTAssertFalse(NSThread.isMainThread(), "This should spawn out different thread")
      }
      
      // verify
      self.context.performBlock { [unowned self] in
        do {
          let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
          guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
          
          XCTAssertEqual(editedUnitTest.name, "Write Async background")
          expectation.fulfill()
        }
        catch { XCTFail() }
      }
    })
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testWriteSyncBackground() {
    let expectation = self.expectationWithDescription("Write Sync Background")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.context = LiteData.sharedInstance.writeContext()
      
      self.context.editEntityAndWait(self.unitTest!) { editingEntity in
        editingEntity.name = "Write Sync Background"
        XCTAssertFalse(NSThread.isMainThread(), "This should stay on same background thread")
      }
      
      // verify
      self.context.performBlockAndWait { [unowned self] in
        do {
          let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
          guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
          
          XCTAssertEqual(editedUnitTest.name, "Write Sync Background")
        }
        catch { XCTFail() }
      }
      
      expectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  // MARK: - Abnormal Behavior - Main context should be for read-only
  
  func testMainContextWriteAsync() {
    let expectation = self.expectationWithDescription("Main Context Write Async")
    context = LiteData.sharedInstance.mainContext
    
    context.editEntity(self.unitTest!) { editingEntity in
      editingEntity.name = "Main Context Write Async"
      XCTAssertTrue(NSThread.isMainThread(), "This should run on main thread anyway")
    }
    
    context.performBlock { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Main Context Write Async")
        expectation.fulfill()
      }
      catch { XCTFail() }
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testMainContextWriteSync() {
    context = LiteData.sharedInstance.mainContext
    
    context.editEntityAndWait(self.unitTest!) { editingEntity in
      editingEntity.name = "Main Context Write Sync"
      XCTAssertTrue(NSThread.isMainThread(), "This should also run on main thread")
    }
    
    // verify
    context.performBlockAndWait { [unowned self] in
      do {
        let fetchResults = try self.context.executeFetchRequest(self.fetchRequest)
        guard let editedUnitTest: UnitTest = (fetchResults as? Array)?.first else { XCTFail(); return }
        
        XCTAssertEqual(editedUnitTest.name, "Main Context Write Sync")
      }
      catch { XCTFail() }
    }
  }
}
