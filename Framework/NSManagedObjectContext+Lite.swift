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
  
  class func childContextWithParent(parentContext: NSManagedObjectContext, name: String) -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.name = name
    context.parentContext = parentContext
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }
  
  func safeSave() {
    if hasChanges {
      do {
        try save()
      } catch {
        print("Error saving: \(error as NSError)")
      }
    }
  }
  
  func safeRecursiveSave() {
    if let _parentContext = parentContext where _parentContext.hasChanges {
      do {
        try _parentContext.save()
      } catch {
        print("Error saving parent: \(error as NSError)")
      }
    }
  }
}

// MARK: Asynchronous API

extension NSManagedObjectContext {
  
  func createEntity<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((creatingEntity: T) -> ())? ) {
    
    performBlock { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.createEntityUnSafe(entityClass, persisted: persisted, setValue: setValue)
    }
  }
  
  func editEntity<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    performBlock { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.editEntityUnsafe(entity, persisted: persisted, setValue: setValue)
    }
  }
  
  func deleteEntity<T: NSManagedObject>(entity: T, persisted: Bool) {
    
    performBlock { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.deleteEntityUnsafe(entity, persisted: persisted)
    }
  }
}

// MARK: Synchronous API

extension NSManagedObjectContext {
  
  func createEntityAndWait<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((creatingEntity: T) -> ())? ) {
    
    performBlockAndWait { [unowned self] in
      self.createEntityUnSafe(entityClass, persisted: false, setValue: setValue)
    }
    
    if (persisted) {
      persistAndWait()
    }
  }
  
  func editEntityAndWait<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    performBlockAndWait { [unowned self] in
      self.editEntityUnsafe(entity, persisted: false, setValue: setValue)
    }
    
    if (persisted) {
      persistAndWait()
    }
  }
  
  func deleteEntityAndWait<T: NSManagedObject>(entity: T, persisted: Bool = true) {
    
    performBlockAndWait { [unowned self] in
      self.deleteEntityUnsafe(entity, persisted: persisted)
    }
    
    if (persisted) {
      persistAndWait()
    }
  }
  
  private func persistAndWait() {
    performBlockAndWait { [unowned self] in
      self.safeSave()
    }
    
    parentContext?.performBlockAndWait { [unowned self] in
      self.safeRecursiveSave()
    }
  }
}

// MARK: - Private

extension NSManagedObjectContext {
  
  private func createEntityUnSafe<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((creatingEntity: T) -> ())? ) {
    
    let entityName = ClassDescriptor<T>().className
    guard let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self) else { return }
    
    let entity = T(entity: entityDescription, insertIntoManagedObjectContext: self)
    
    if let setValueBlock = setValue {
      setValueBlock(creatingEntity: entity)
    }
    
    if persisted {
      persistUnsafe()
    }
  }
  
  private func editEntityUnsafe<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    let localEntity = self.objectWithID(entity.objectID) 
    
    if let setValueBlock = setValue {
      setValueBlock(editingEntity: (localEntity as! T))
    }
    
    if persisted {
      persistUnsafe()
    }
  }
  
  private func deleteEntityUnsafe<T: NSManagedObject>(entity: T, persisted: Bool = true) {
    let localEntity = self.objectWithID(entity.objectID)
    
    self.deleteObject(localEntity)
    
    if persisted {
      persistUnsafe()
    }
  }
  
  private func persistUnsafe() {
    self.safeSave()
    
    /* 
     * this may cause dead lock when called on main thread with parent context in main thread
     * it should not happen with our moc hierachy setup
     * however, if we ever use these extension with a different moc hierachy setup, warning!
     */
    self.parentContext?.performBlockAndWait { [unowned self] in
      self.safeRecursiveSave()
    }
  }
}