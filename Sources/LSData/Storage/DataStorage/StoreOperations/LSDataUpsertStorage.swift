import Foundation
import Combine

public protocol DataUpsertStorage: DataStorage {
        
    func upsert(_ item: StoredItem) -> StorageReturn
}

extension DataUpsertStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        upsert(item)
    }
}
