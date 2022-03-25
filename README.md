LSData is a lightweight framework that aims to completely abstract and generalise iOS model layer. 

Concrete implementations, such as `CoreData`, `UserDefaults`, `Keychain` and networking layer are available in __[LSCocoa framework](https://github.com/dinogustinn/LSCocoa)__ which are almost exclusively used together (unless you wish to write your own implementations).

The goal is to provide complex functionalities such as caching, syncing (i.e. syncing local database with backend), and refreshing, to any entities conforming to protocols in these frameworks. This would mean that all these functionalities are available out of the box.

Common use-cases (provided as basically one-liners to all classes conforming to these protocols):
+ Sync your `CoreData` database with your backend database and vice-versa
+ Cache, refresh and query your network requests
+ Provide oAuth functionality with automatic refresh of tokens if needed on every request
+ Redirect data flow to local if network is not available
+ Many other, limited by your imagination :)

There are 3 main protocols in this framework explained below


### Data Source

    protocol DataSource {
    
        associatedtype Output    
        associatedtype Parameter = Void
        associatedtype OutputError: Error = Error
    
        func publisher(parameter: Parameter) -> AnyPublisher<Output, OutputError>
    }
`DataSource` is a simple protocol used as a source of data. It uses Apple's `Combine` framework to provide reactivity. It is similar to Combine's `Publisher` except it can optionally be queried by `Parameter`.

### Data Storage

    protocol DataStorage {
    
        associatedtype StoredItem
        associatedtype StorageReturn = Void
    
        func store(_ item: StoredItem) -> StorageReturn
    }
`DataStorage` is a protocol providing storage functionality (such as saving items to `CoreData` or to your network endpoint). `StoredItem` is often an array of elements (such as `[User]`).

### Data Storage

    protocol DeletableStorage {
        associatedtype DeletableItem
        associatedtype DeletionReturn = Void
    
        func delete(_ item: DeletableItem) -> DeletionReturn
        
        func deleteAll() -> DeletionReturn
    }

`DeletableStorage` is a protocol provoding deletion functionality. Most concrete `DataStorage` (mentioned above) implementations might provide conform to `DeletableStorage` as well, having `DeletableItem` and `StoredItem` be the same type.
