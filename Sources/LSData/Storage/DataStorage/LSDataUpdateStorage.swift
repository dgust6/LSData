import Foundation
import Combine

public protocol DataUpdateStorage: DataStorage {
        
    func update(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError>
}

extension DataUpdateStorage {
    func store(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError> {
        update(item)
    }
}
