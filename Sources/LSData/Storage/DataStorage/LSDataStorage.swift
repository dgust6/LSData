import Foundation
import Combine

public protocol DataStorage {
    associatedtype StoredItem
    associatedtype StorageError: Error = Error
    associatedtype StorageReturn = Void
    
    func store(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError>
}

extension DataStorage {
    func erase() -> LSAnyDataStorage<StoredItem, StorageReturn, StorageError> {
        LSAnyDataStorage(storage: self)
    }
}

public class LSAnyDataStorage<StoredItem, StorageReturn, StorageError>: DataStorage where StorageError: Error {

    public typealias StoredItem = StoredItem
    public typealias StorageError = StorageError
    public typealias StorageReturn = StorageReturn
    
    private let _store: ((StoredItem) -> AnyPublisher<StorageReturn, StorageError>)
    
    public init<Storage: DataStorage>(storage: Storage) where Storage.StoredItem == StoredItem, Storage.StorageError == StorageError, Storage.StorageReturn == StorageReturn {
        _store = storage.store
    }
    
    public func store(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError> {
        _store(item)
    }
}
