//
//  LiteData.swift
//  LiteData
//
//  Created by PC on 10/15/15.
//  Copyright © 2015 PC. All rights reserved.
//

import Foundation
import CoreData

class LiteData {
  
  // MARK: - Singleton
  
  static let sharedInstance = LiteData()
  
  // MARK: - Setup
  
  lazy var modelURL: NSURL = {
    let applicationName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    let _modelURL = NSBundle.mainBundle().URLForResource(applicationName, withExtension: "momd")!
    return _modelURL
    }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    let _managedObjectModel = NSManagedObjectModel(contentsOfURL: self.modelURL)!
    return _managedObjectModel
    }()
  
  var storeType = NSSQLiteStoreType
  
  lazy var storeURL: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    let directoryURL = urls[urls.count-1]
    let applicationName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    let _storeURL = directoryURL.URLByAppendingPathComponent("\(applicationName).sqlite")
    return _storeURL
    }()
  
  var storeOptions = [
    NSMigratePersistentStoresAutomaticallyOption : true,
    NSInferMappingModelAutomaticallyOption : true
  ]
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let _coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    
    do {
      try _coordinator.addPersistentStoreWithType(self.storeType, configuration: nil, URL: self.storeURL, options: self.storeOptions)
    } catch {
      NSLog("Unresolved error \(error), \((error as NSError).userInfo)")
      abort()
    }
    
    return _coordinator
    }()
  
  // MARK: - MOC Hierachy
  
  lazy var rootContext: NSManagedObjectContext = {
    let _rootContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    _rootContext.name = "com.litedata.write.context.root"
    _rootContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    _rootContext.mergePolicy = NSOverwriteMergePolicy //TEST:
    _rootContext.undoManager = nil //LEARN:
    return _rootContext
    }()
  
  lazy var mainContext: NSManagedObjectContext = {
    let _mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    _mainContext.name = "com.litedata.read.context.main"
    _mainContext.parentContext = self.rootContext
    _mainContext.mergePolicy = NSRollbackMergePolicy //TEST:
    _mainContext.undoManager = nil
    return _mainContext
    }()
  
  func writeContext(id: String = "com.litedata.write.context.child") -> NSManagedObjectContext {
    let childContext = NSManagedObjectContext.childContextWithParent(self.rootContext, name: id)
    return childContext
  }
}



extension LiteData {
  class func entity<T: NSManagedObject>(entity: T) -> DataEntity<T> {
    let dataEntity = DataEntity<T>(entity: entity)
    dataEntity.destinationContext = LiteData.sharedInstance.writeContext()
    
    return dataEntity
  }
  
  class func entity<T: NSManagedObject>(entityClass: T.Type) -> DataEntity<T> {
    let dataEntity = DataEntity<T>(entityClass: entityClass)
    dataEntity.destinationContext = LiteData.sharedInstance.writeContext()
    
    return dataEntity
  }
}