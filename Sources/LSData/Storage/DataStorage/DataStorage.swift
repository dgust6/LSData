import Foundation
import Combine

/// Protocol defining a data storage/repository.
///
/// It supplies the method `store` which should store the supplied item.
/// In many use-cases this `StoredItem` will be an array of supplied type.
public protocol DataStorage<StoredItem, StorageReturn> {
    associatedtype StoredItem
    associatedtype StorageReturn = Void
    
    /// Stores the supplied `item`.
    func store(_ item: StoredItem) -> StorageReturn
}

public enum StorageDeallocationError: Error {
    case deallocated
}

public extension DataSource {
    
    /// Stores the output to supplied `storage`.
    ///
    /// `count` parameter defines number of times data is stored before terminating. `count` of 0 means that indefinite storage (each time data is outputted, it's stored).
    func store<Storage: DataStorage>(toPublished storage: Storage, parameter: Parameter, count: Int = 1) -> AnyPublisher<Storage.StorageReturn.Output, Error> where Output == Storage.StoredItem, Storage.StorageReturn: Publisher {
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
    
    /// Stores the output to supplied `storage`.
    ///
    /// `count` parameter defines number of times data is stored before terminating. `count` of 0 means that indefinite storage (each time data is outputted, it's stored).
    func store<Storage: DataStorage>(to storage: Storage, parameter: Parameter, count: Int = 1) -> AnyPublisher<Storage.StorageReturn, Error> where Output == Storage.StoredItem {
        let mappedStorage = storage.resultMap(with: ToPublisherMapper<Storage.StorageReturn>())
        return self.store(toPublished: mappedStorage, parameter: parameter, count: count)
    }
}
