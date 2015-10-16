//
//  NSManagedObjectContext+Lite.swift
//  LiteData
//
//  Created by PC on 10/15/15.
//  Copyright © 2015 PC. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
  static let childName = "com.litedata.write.context.child"
  
  class func childContextWithParent(parentContext: NSManagedObjectContext, name: String? = childName) -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.parentContext = parentContext
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }
}
