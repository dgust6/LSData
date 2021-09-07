import Foundation
import Combine

public protocol DeletableStorage {
    associatedtype StoredItem
    associatedtype DeletionError: Error = Error
    associatedtype DeletionReturn = Void
    
    func delete(_ item: StoredItem) -> AnyPublisher<DeletionReturn, DeletionError>
        
    func deleteAll() -> AnyPublisher<DeletionReturn, DeletionError>
}
