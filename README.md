# LiteData
A light weight wrapper around core data in swift.
The goal of this project is to provide different layer of abstraction on top of core data, so that depends on the need we can use a higher level of abstraction for convenient or simply drop down to the next layer to have more interaction and flexibility

## LiteData layer
This provide the highest abstraction (for now). We can use this anywhere on main thread for read/write operation without having to worry about the MOC interaction behind the scene. It provides dot notation to chain operation

The text inside ## are place holder

- To insert a Book object
```Swift
LiteData.entity(Book).add({ creatingBook in
  creatingBook.title = "A mid summer night dream"
  creatingBook.author = "Sharespear"
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
LiteData.entity(sharespearBook).delete().persist {
  // completion block
}
```

## NSManagedObject Context Layer
