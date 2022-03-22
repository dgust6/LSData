import Foundation
import Combine

public protocol DataUpdateStorage: DataStorage {
        
    func update(_ item: StoredItem) -> StorageReturn
}

public extension DataUpdateStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        update(item)
    }
}
