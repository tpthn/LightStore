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
    context.performBlockAndWait { [weak self, fetchRequest] in
      do {
        guard let fetchResults = try self?.context.executeFetchRequest(fetchRequest) else { XCTFail(); return }
        self?.fetchCount = fetchResults.count
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
  
  var fetchCount = 0
}
