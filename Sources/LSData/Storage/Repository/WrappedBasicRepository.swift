import Foundation
import Combine

open class WrappedBasicRepository<Source: DataSource, Storage: DataStorage, Deletable: DeletableStorage>: DataBasicRepository where Storage.StoredItem? == Source.Output, Storage.StoredItem == Deletable.DeletableItem {
    
    public typealias StoredItem = Storage.StoredItem
    public typealias StorageReturn = Storage.StorageReturn
    public typealias OutputError = Source.OutputError
    public typealias Parameter = Source.Parameter
    public typealias Output = Source.Output
    public typealias DeletableItem = Storage.StoredItem
    public typealias DeletionReturn = Deletable.DeletionReturn
    
    private let source: Source
    private let storage: Storage
    private let deletable: Deletable
    
    public init(source: Source, storage: Storage, deletable: Deletable) {
        self.source = source
        self.storage = storage
        self.deletable = deletable
    }
    
    open func store(_ item: StoredItem) -> StorageReturn {
        storage.store(item)
    }
    
    open func publisher(parameter: Parameter) -> AnyPublisher<Output, OutputError> {
        source.publisher(parameter: parameter)
    }
    
    open func delete(_ item: StoredItem) -> Deletable.DeletionReturn {
        deletable.delete(item)
    }
    
    open func deleteAll() -> DeletionReturn {
        deletable.deleteAll()
    }
}
