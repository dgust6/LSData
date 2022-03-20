import Foundation
import Combine

public protocol DataStorage {
    associatedtype StoredItem
    associatedtype StorageReturn = Void
    
    func store(_ item: StoredItem) -> StorageReturn
}

extension DataStorage {
    func erase() -> LSAnyDataStorage<StoredItem, StorageReturn> {
        LSAnyDataStorage(storage: self)
    }
}

public class LSAnyDataStorage<StoredItem, StorageReturn>: DataStorage {

    public typealias StoredItem = StoredItem
    public typealias StorageReturn = StorageReturn
    
    private let _store: ((StoredItem) -> StorageReturn)
    
    public init<Storage: DataStorage>(storage: Storage) where Storage.StoredItem == StoredItem, Storage.StorageReturn == StorageReturn {
        _store = storage.store
    }
    
    public func store(_ item: StoredItem) -> StorageReturn {
        _store(item)
    }
}
