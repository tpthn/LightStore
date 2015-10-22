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
  
  func recursiveSave() {
    if self.hasChanges {
      do {
        try self.attemptRecursiveSave()
      } catch {
        print("Error saving: \(error as NSError)")
      }
    }
  }
  
  func attemptRecursiveSave() throws {
    try self.save()
  }
}

// MARK: Asynchronous API

extension NSManagedObjectContext {
  
  func createEntity<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((creatingEntity: T) -> ())? ) {
    
    self.performBlock { [weak self] in
      self?.createEntityUnSafe(entityClass, persisted: persisted, setValue: setValue)
    }
  }
  
  func editEntity<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    self.performBlock { [weak self] in
      self?.editEntityUnsafe(entity, persisted: persisted, setValue: setValue)
    }
  }
  
  func deleteEntity<T: NSManagedObject>(entity: T, persisted: Bool) {
    
    self.performBlock { [weak self] in
      self?.deleteEntityUnsafe(entity, persisted: persisted)
    }
  }
}

// MARK: Synchronous API

extension NSManagedObjectContext {

  func createEntityAndWait<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((creatingEntity: T) -> ())? ) {
    
    self.performBlockAndWait { [weak self] in
      self?.createEntityUnSafe(entityClass, persisted: persisted, setValue: setValue)
    }
  }
  
  func editEntityAndWait<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    self.performBlockAndWait { [weak self] in
      self?.editEntityUnsafe(entity, persisted: persisted, setValue: setValue)
    }
  }
  
  func deleteEntityAndWait<T: NSManagedObject>(entity: T, persisted: Bool = true) {
    
    self.performBlockAndWait { [weak self] in
      self?.deleteEntityUnsafe(entity, persisted: persisted)
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
      self.recursiveSave()
    }
  }
  
  private func editEntityUnsafe<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    guard let localEntity = self.objectRegisteredForID(entity.objectID) else {
      //TODO: handle non registered objects
      return;
    }
    
    if let setValueBlock = setValue {
      setValueBlock(editingEntity: (localEntity as! T))
    }
    
    if persisted {
      self.recursiveSave()
    }
  }
  
  private func deleteEntityUnsafe<T: NSManagedObject>(entity: T, persisted: Bool = true) {
    guard let localEntity = self.objectRegisteredForID(entity.objectID) else {
      //TODO: handle non registered objects
      return;
    }
    
    self.deleteObject(localEntity)
    
    if persisted {
      self.recursiveSave()
    }
  }
}