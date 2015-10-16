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
  
  override func setUp() {
    super.setUp()
    
    // make sure we come from empty state
    context.performBlockAndWait { [weak self, fetchRequest] in
      do {
        guard let fetchResults = try self?.context.executeFetchRequest(fetchRequest) else { XCTFail(); return }
        self?.fetchCount = fetchResults.count
      }
      catch { XCTFail() }
    }
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testCreateEntity() {
    let expectation = self.expectationWithDescription("Create Entity Asynchronously")
    
    context.createEntity(UnitTest.self) { createdEntity in
      createdEntity.name = "Create Entity Asynchronous"
    }
    
    // verify
    context.performBlock { [weak self, fetchRequest, fetchCount] in
      do {
        guard let fetchResults = try self?.context.executeFetchRequest(fetchRequest) else { XCTFail(); return }
        XCTAssertTrue(fetchResults.count == (fetchCount + 1))
        expectation.fulfill()
      }
      catch { XCTFail() }
    }
    
    self.waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testCreateEntityAndWait() {
    
    context.createEntityAndWait(UnitTest.self) { createdEntity in
      createdEntity.name = "Create Entity Asynchronous"
    }
    
    do {
      let fetchResults = try context.executeFetchRequest(fetchRequest)
      XCTAssertTrue(fetchResults.count == (fetchCount + 1))
    }
    catch { XCTFail() }
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
  
  var fetchCount = 0
}