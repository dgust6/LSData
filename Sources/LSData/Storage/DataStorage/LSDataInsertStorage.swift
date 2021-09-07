import Foundation
import Combine

public protocol DataInsertStorage: DataStorage {
        
    func insert(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError>
}

extension DataInsertStorage {
    func store(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError> {
        insert(item)
    }
}
