import Foundation
import Combine

/// Protocol defining deletable storage.
///
/// Deletable storage 
public protocol DeletableStorage {
    associatedtype DeletableItem
    associatedtype DeletionReturn = Void
    
    func delete(_ item: DeletableItem) -> DeletionReturn
        
    func deleteAll() -> DeletionReturn
}
