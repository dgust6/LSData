import Foundation
import Combine

public protocol DataBasicRepository: DataSource, DataStorage, DeletableStorage where Output == StoredItem?, DeletableItem == StoredItem {

}

open class AnyDataBasicRepository<StoredItem, QueryParameter, OutputError, StorageReturn, DeletionReturn>: DataBasicRepository where OutputError: Error {
    
    public typealias Output = StoredItem?
    public typealias Parameter = QueryParameter
    public typealias OutputError = OutputError
    public typealias StoredItem = StoredItem
    public typealias StorageReturn = StorageReturn
    public typealias DeletableItem = StoredItem
    public typealias DeletionReturn = DeletionReturn
    
    private let _publisher: ((QueryParameter) -> AnyPublisher<Output, OutputError>)
    private let _store: ((StoredItem) -> StorageReturn)
    private let _delete: ((DeletableItem) -> DeletionReturn)
    private let _deleteAll: (() -> DeletionReturn)

    public init<Repository: DataBasicRepository>(repository: Repository) where Repository.StoredItem == StoredItem, Repository.StorageReturn == StorageReturn, Repository.OutputError == OutputError, Repository.Parameter == Parameter, Repository.DeletionReturn == DeletionReturn {
        _store = repository.store
        _publisher = repository.publisher
        _delete = repository.delete
        _deleteAll = repository.deleteAll
    }
    
    public init<Storage: DataStorage, Source: DataSource, Deletable: DeletableStorage>(storage: Storage, source: Source, deletable: Deletable) where Storage.StoredItem == StoredItem, Storage.StorageReturn == StorageReturn, Source.OutputError == OutputError, Source.Parameter == Parameter, Source.Output == Output, Deletable.DeletableItem == Output, Deletable.DeletionReturn == DeletionReturn {
        _store = storage.store
        _publisher = source.publisher
        _delete = deletable.delete
        _deleteAll = deletable.deleteAll
    }

    open func publisher(parameter: QueryParameter) -> AnyPublisher<Output, OutputError> {
        _publisher(parameter)
    }
    
    open func store(_ item: StoredItem) -> StorageReturn {
        _store(item)
    }
    
    public func delete(_ item: StoredItem) -> DeletionReturn {
        _delete(item)
    }
    
    public func deleteAll() -> DeletionReturn {
        _deleteAll()
    }
}
