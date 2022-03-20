import Foundation
import Combine

public protocol DeletableStorage {
    associatedtype StoredItem
    associatedtype DeletionReturn = Void
    
    func delete(_ item: StoredItem) -> DeletionReturn
        
    func deleteAll() -> DeletionReturn
}
