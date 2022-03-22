import Foundation
import Combine

public protocol DataStorage {
    associatedtype StoredItem
    associatedtype StorageReturn = Void
    
    func store(_ item: StoredItem) -> StorageReturn
}

public extension DataStorage {
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

public enum StorageDeallocationError: Error {
    case deallocated
}

public extension DataSource {
    func store<Storage: DataStorage>(to storage: Storage, parameter: Parameter, count: Int = 1) -> AnyPublisher<Storage.StorageReturn.Output, Error> where Output == Storage.StoredItem, Storage.StorageReturn: Publisher {
        weak var weakStorage = storage as AnyObject
        
        let publisher = count == 0 ?
        publisher(parameter: parameter).eraseToAnyPublisher()
            : publisher(parameter: parameter).prefix(count).eraseToAnyPublisher()
        
        return publisher
            .tryMap { item -> AnyPublisher<Storage.StorageReturn.Output, Error> in
                guard let storage = weakStorage as? Storage else { throw StorageDeallocationError.deallocated }
                return storage
                    .store(item)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    func store<Storage: DataStorage>(to storage: Storage, parameter: Parameter, count: Int = 1) -> AnyPublisher<Storage.StorageReturn, Error> where Output == Storage.StoredItem {
        let mappedStorage = storage.resultMap(with: LSToPublisherMapper<Storage.StorageReturn>())
        return self.store(to: mappedStorage, parameter: parameter, count: count)
    }
}
