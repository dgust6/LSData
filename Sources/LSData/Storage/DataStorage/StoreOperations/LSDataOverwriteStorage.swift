import Foundation
import Combine

public protocol DataOverwriteStorage: DataStorage {
        
    func overwriteAll(_ item: StoredItem) -> StorageReturn
}

extension DataOverwriteStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        overwriteAll(item)
    }
}
