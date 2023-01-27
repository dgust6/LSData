import Foundation
import Combine

public protocol DataGeneralStorage: DataInsertStorage, DataOverwriteStorage, DataUpsertStorage, DataUpdateStorage { }

public extension DataGeneralStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        overwriteAll(item)
    }
}
