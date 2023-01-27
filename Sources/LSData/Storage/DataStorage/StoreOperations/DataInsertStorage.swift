import Foundation
import Combine

/// `DataStorage` with insert functionality.
public protocol DataInsertStorage: DataStorage {
        
    /// Inserts the supplied `item` in storage.
    ///
    /// If the item already exists, nothing happens (it's not updated). If updating in this case is needed look at `LSUpdateDataStorage`
    func insert(_ item: StoredItem) -> StorageReturn
}

public extension DataInsertStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        insert(item)
    }
}
