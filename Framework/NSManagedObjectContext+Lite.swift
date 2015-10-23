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
    if self.hasChanges {
      do {
        try self.save()
      } catch {
        print("Error saving: \(error as NSError)")
      }
    }
  }
  
  func safeRecursiveSafe() {
    if let _parentContext = self.parentContext where _parentContext.hasChanges {
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
    
    self.performBlock { [weak self] in
      self?.createEntityUnSafe(entityClass, persisted: persisted, setValue: setValue)
      
      if (persisted) {
        self?.parentContext?.performBlockAndWait { [weak self] in
          self?.safeRecursiveSafe()
        }
      }
    }
  }
  
  func editEntity<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    self.performBlock { [weak self] in
      self?.editEntityUnsafe(entity, persisted: persisted, setValue: setValue)
      
      if (persisted) {
        self?.parentContext?.performBlockAndWait { [weak self] in
          self?.safeRecursiveSafe()
        }
      }
    }
  }
  
  func deleteEntity<T: NSManagedObject>(entity: T, persisted: Bool) {
    
    self.performBlock { [weak self] in
      self?.deleteEntityUnsafe(entity, persisted: persisted)
      
      if (persisted) {
        self?.parentContext?.performBlockAndWait { [weak self] in
          self?.safeRecursiveSafe()
        }
      }
    }
  }
}

// MARK: Synchronous API

extension NSManagedObjectContext {

  func createEntityAndWait<T: NSManagedObject>(entityClass: T.Type, persisted: Bool = true, setValue: ((creatingEntity: T) -> ())? ) {
    
    self.performBlockAndWait { [weak self] in
      self?.createEntityUnSafe(entityClass, persisted: persisted, setValue: setValue)
    }
    
    if (persisted) {
      self.parentContext?.performBlockAndWait { [weak self] in
        self?.safeRecursiveSafe()
      }
    }
  }
  
  func editEntityAndWait<T: NSManagedObject>(entity: T, persisted: Bool = true, setValue: ((editingEntity: T) -> ())? ) {
    
    self.performBlockAndWait { [weak self] in
      self?.editEntityUnsafe(entity, persisted: persisted, setValue: setValue)
    }
    
    if (persisted) {
      self.parentContext?.performBlockAndWait { [weak self] in
        self?.safeRecursiveSafe()
      }
    }
  }
  
  func deleteEntityAndWait<T: NSManagedObject>(entity: T, persisted: Bool = true) {
    
    self.performBlockAndWait { [weak self] in
      self?.deleteEntityUnsafe(entity, persisted: persisted)
    }
    
    if (persisted) {
      self.parentContext?.performBlockAndWait { [weak self] in
        self?.safeRecursiveSafe()
      }
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
      self.safeSave()
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
      self.safeSave()
    }
  }
  
  private func deleteEntityUnsafe<T: NSManagedObject>(entity: T, persisted: Bool = true) {
    guard let localEntity = self.objectRegisteredForID(entity.objectID) else {
      //TODO: handle non registered objects
      return;
    }
    
    self.deleteObject(localEntity)
    
    if persisted {
      self.safeSave()
    }
  }
}