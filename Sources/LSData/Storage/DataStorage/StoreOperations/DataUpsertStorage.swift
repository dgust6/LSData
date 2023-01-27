import Foundation
import Combine

/// `DataStorage` with upsert functionality.
///
/// Upsert is a combination of insert and update. It updates the item if it exists or inserts if it doesn't.
public protocol DataUpsertStorage: DataStorage {
     
    /// Upserts the supplied `item` into storage.
    func upsert(_ item: StoredItem) -> StorageReturn
}

public extension DataUpsertStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        upsert(item)
    }
}
