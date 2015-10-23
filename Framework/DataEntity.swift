//
//  DataEntity.swift
//  LiteData
//
//  Created by PC on 10/20/15.
//  Copyright © 2015 PC. All rights reserved.
//

import Foundation
import CoreData

/*
LiteData.entity(UnitTest.self).add({creatingEntity in
// entity property goes here
}).persist({ createdEntity, status in
// handle newly created entity and / or error here
})

LiteData.entity(someObject).edit({editingEntity in
// entity property goes here
}).persist({ editedEntity, status in
// handle edited entity and / or error here
})

LiteData.entity(someObject).delete({ status in

})

LiteData.readEntity(UnitTest.self).fetch(predicateFormat) { results in

}

LiteData.readEntity(UnitTest.self).fetchOne(predicateFormat)

let entity = LiteData.readEntity(UnitTest.self)
entity.sort(sortDescriptor)
entity.batch(10)
entity.fetch(predicateFormat) {results in

}
*/

class DataEntity<T: NSManagedObject> {
  
  var destinationContext: NSManagedObjectContext?
  var entity: T?
  
  let entityClass: T.Type
  
  init(entityClass: T.Type) {
    self.entityClass = entityClass
  }
  
  init(entity: T) {
    self.entity = entity
    self.entityClass = T.self
  }
  
  func add(setValue: ((creatingEntity: T) -> ())? ) -> DataEntity<T> {
    destinationContext?.createEntity(T.self, persisted: false) { [weak self] creatingEntity in
      self?.entity = creatingEntity
    }
    
    return self;
  }
  
  func edit(setValue: ((creatingEntity: T) -> ()) ) -> DataEntity<T> {
    if let _entity = entity {
      destinationContext?.editEntity(_entity, persisted: false, setValue: setValue)
    }
    
    return self;
  }
  
  func delete() -> DataEntity<T> {
    if let _entity = entity {
      destinationContext?.deleteEntity(_entity, persisted: false)
    }
    
    return self;
  }
  
  func persist() {
    destinationContext?.performBlock { [weak destinationContext] in
      destinationContext?.safeSave()
      if let parentContext = destinationContext?.parentContext where parentContext.hasChanges {
        parentContext.performBlockAndWait { [weak parentContext] in
          parentContext?.safeSave()
        }
      }
    }
  }
  
  func persist(completion: (persistedEntity: T?, error: NSError?) -> ()) {
    destinationContext?.performBlock({ [weak destinationContext] in
      do {
        if let _ = destinationContext?.hasChanges {
          try destinationContext?.save()
        }
        
        if let parentContext = destinationContext?.parentContext where parentContext.hasChanges {
          parentContext.performBlockAndWait { [weak parentContext] in
            do {
              try parentContext?.save()
            } catch {
              completion(persistedEntity: nil, error: error as NSError)
            }
          }
        }
        
        completion(persistedEntity: self.entity, error: nil)
      } catch {
        completion(persistedEntity: nil, error: error as NSError)
      }
    })
  }
}