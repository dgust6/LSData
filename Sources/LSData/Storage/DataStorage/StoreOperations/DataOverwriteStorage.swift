import Foundation
import Combine

/// `DataStorage` with overwrite functionality.
public protocol DataOverwriteStorage: DataStorage {

    /// Overwrites the supplied `item` in storage.
    ///
    /// Overwrite means everything currently in storage is replace with supplied item.
    func overwriteAll(_ item: StoredItem) -> StorageReturn
}

public extension DataOverwriteStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        overwriteAll(item)
    }
}
