# LiteData
A light weight wrapper around core data in swift.
The goal of this project is to provide different layer of abstraction on top of core data, so that depends on the need we can use a higher level of abstraction for convenient or simply drop down to the next layer to have more interaction and flexibility

### Managed Object Layer (TO DO)
Let's be plain. we don't want to deal with MOC interaction, we don't want to call a custom class to perform core data operation. Sometimes we just want deal with the managed objects themselves. This provide the highest abstraction. Thus it lacks of features such as temporary (unsaved) objects and completion block. However, it gives the best simplicity and very useful for batch operations. 

##### Write Operation

- To insert a Book object
``` Swift
Book.add { creatingBook in
  creatingBook.title = "A mid summer night dream"
  creatingBook.author = "Shakespear"
}
```

- Then edit it
``` Swift
shakespearBook.edit { editingBook in
  editingBook.publisher = "The Great Publisher"  
}
```

- And if we want to delete it
``` Swift
shakespearBook.remove() 
```

- Batch operation
``` Swift
LiteData.batchOperation {
  let author = Author.add { creatingAuthor in
    creatingAuthor.name = "Shakespear"
  }

  Book.add { creatingBook in
    creatingBook.title = "A mid summer night dream"
    creatingBook.publisher = "The Great Publisher"
    creatingBook.author = author
  }
}

##### Read Operation

TODO:

### LiteData layer (IN PROGRESS)
This provide the next level of abstraction. We can use this anywhere on main thread for read/write operation without having to worry about the MOC interaction behind the scene. It provides dot notation to chain operations

##### Write Operation

- To insert a Book object
```Swift
LiteData.entity(Book.self).add({ creatingBook in
  creatingBook.title = "A mid summer night dream"
  creatingBook.author = "Shakespear"
}).persist()
```
- Then edit it
```Swift
LiteData.entity(shakespearBook).edit({ editingBook in
  editingBook.publisher = "The Great Publisher"
}).persist()
```
- And if we want to delete it
```Swift
LiteData.entity(shakespearBook).remove().persist {
  // completion closure
}
```
- If we want to just create the object and not persist it immediately, we can store it in a DataEntity variable
```Swift
let adventureBook = LiteData.entity(Book.self).add { creatingBook in
  creatingBook.title = "The adventure of Tom Sawyer"
  creatingBook.author = "Mark Twain"
}

// later on call
adventureBook.persist {
  // completion closure
}
```
##### Read Opearation

- Get one book
``` Swift
let tomSawyerBook = LiteData.readEntity(Book.self).fetch(predicate)
```
- Get some book
``` Swift
let literatureBooks = LiteData.readEntity(Book.self).fetch(predicate)
```
- Batching
``` Swift
let adventureBooks = LiteData.readEntity(Book.self).batch(10).fetch(predicate)
```

- Sorting
``` Swift
let adventureBooks = LiteData.readEntity(Book.self).sort(sortDescriptor).fetch(predicate)
```

- Let's try something complicated
``` Swift
let readEntity = LiteData.readEntity(Book.self)
readEntity.batch(10)
readEntity.sort(sortDescriptor)

let adventureBooks = readEntity.fetch()

\\ Not too bad? :)
```

##### Observing Changes

TODO:

###### Notes
- All write operation happens asynchronously and not blocking the main thread.
- A DataEntity object is returned at the end of any operation during the chain
- You can call persist with completion closure or simply call persist(). The completion closure is returned on the background thread. You have the option to dispatch_async back to main thread to perform any UI updates.
- These are just specs at the moment. This is a WORK IN PROGRESS and TENTATIVE TO CHANGE depends on the technical feasibility
 
### NSManagedObject Context Layer

TODO:
