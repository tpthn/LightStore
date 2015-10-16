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
  
  class func childContextWithParent(parentContext: NSManagedObjectContext, name: String = "com.litedata.write.context.child") -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.name = name
    context.parentContext = parentContext
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }
  
  func recursiveSave() {
    if self.hasChanges {
      do {
        try self.save()
      } catch {
        print("Error saving: \(error as NSError)")
      }
    }
  }
}

// MARK: Asynchronous API

extension NSManagedObjectContext {
  
  func createEntity<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((createdEntity: T) -> ())? ) {
    
    self.performBlock { [weak self] in
      self?.createEntityUnSafe(entityClass, persisted: persisted, setValue: setValue)
    }
  }
}

// MARK: Synchronous API

extension NSManagedObjectContext {

  func createEntityAndWait<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((createdEntity: T) -> ())? ) {
    
    self.performBlockAndWait { [weak self] in
      self?.createEntityUnSafe(entityClass, persisted: persisted, setValue: setValue)
    }
  }
}

// MARK: - Private

extension NSManagedObjectContext {
  
  private func createEntityUnSafe<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((createdEntity: T) -> ())? ) {
    
    let entityName = ClassDescriptor<T>().className
    guard let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self) else { return }
    
    let entity = T(entity: entityDescription, insertIntoManagedObjectContext: self)
    
    if let setValueBlock = setValue {
      setValueBlock(createdEntity: entity)
    }
    
    if persisted {
      self.recursiveSave()
    }
  }
}