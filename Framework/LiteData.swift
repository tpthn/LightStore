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
  static let sharedInstance = LiteData()
  
  lazy var storeURL: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
    let directoryURL = urls[urls.count-1]
    let applicationName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    let _storeURL = directoryURL.URLByAppendingPathComponent("\(applicationName).sqlite")
    return _storeURL
    }()
  
  lazy var modelURL: NSURL = {
    let applicationName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    let _modelURL = NSBundle.mainBundle().URLForResource(applicationName, withExtension: "momd")!
    return _modelURL
    }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    let _managedObjectModel = NSManagedObjectModel(contentsOfURL: self.modelURL)!
    return _managedObjectModel
    }()
}