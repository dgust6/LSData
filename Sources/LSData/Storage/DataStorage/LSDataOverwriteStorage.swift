import Foundation
import Combine

public protocol DataOverwriteStorage: DataStorage {
        
    func overwriteAll(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError>
}

extension DataOverwriteStorage {
    func store(_ item: StoredItem) -> AnyPublisher<StorageReturn, StorageError> {
        overwriteAll(item)
    }
}
