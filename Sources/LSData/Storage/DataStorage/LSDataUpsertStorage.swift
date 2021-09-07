import Foundation
import Combine

public protocol DataUpsertStorage: DataStorage {
        
    func upsert(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError>
}

extension DataUpsertStorage {
    func store(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError> {
        upsert(item)
    }
}
