import Foundation
import Combine

/// Protocol defining a data repository
///
/// Provides all CRUD methods.
public protocol DataGeneralStorage: DataInsertStorage, DataOverwriteStorage, DataUpsertStorage, DataUpdateStorage {

}

public extension DataGeneralStorage {
    func store(_ item: StoredItem) -> StorageReturn {
        overwriteAll(item)
    }
}
