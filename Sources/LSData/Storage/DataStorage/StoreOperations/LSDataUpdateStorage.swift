import Foundation
import Combine

/// `DataStorage` with update functionality.
public protocol DataUpdateStorage: DataStorage {

    /// Updates the supplied `item` in storage.
    func update(_ item: StoredItem) -> StorageReturn
}

public extension DataUpdateStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        update(item)
    }
}
