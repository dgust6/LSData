import Foundation
import Combine

public protocol DataInsertStorage: DataStorage {
        
    func insert(_ item: StoredItem) -> StorageReturn
}

public extension DataInsertStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        insert(item)
    }
}
