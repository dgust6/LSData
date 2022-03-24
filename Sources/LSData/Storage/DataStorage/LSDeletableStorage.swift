import Foundation
import Combine

/// Protocol defining deletable storage.
///
/// Deletable storage support's deleting of all items or specified item.
public protocol Deletable {
    associatedtype DeletableItem
    associatedtype DeletionReturn = Void
    
    func delete(_ item: DeletableItem) -> DeletionReturn
        
    func deleteAll() -> DeletionReturn
}
