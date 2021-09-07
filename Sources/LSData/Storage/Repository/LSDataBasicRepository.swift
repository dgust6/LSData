import Foundation
import Combine

public protocol DataBasicRepository: DataSource, DataStorage where StoredItem == Output {

}

public class LSAnyDataBasicRepository<Output, QueryParameter, OutputError, StorageReturn, StorageError>: DataBasicRepository where OutputError: Error, StorageError: Error {

    public typealias Output = Output
    public typealias Parameter = QueryParameter
    public typealias OutputError = OutputError
    public typealias StoredItem = Output
    public typealias StorageReturn = StorageReturn
    public typealias StorageError = StorageError
    
    private let _publisher: ((QueryParameter?) -> AnyPublisher<Output, OutputError>)
    private let _store: ((StoredItem) -> AnyPublisher<StorageReturn, StorageError>)

    public init<Repository: DataBasicRepository>(repository: Repository) where Repository.StoredItem == StoredItem, Repository.StorageError == StorageError, Repository.StorageReturn == StorageReturn, Repository.OutputError == OutputError, Repository.Parameter == Parameter {
        _store = repository.store
        _publisher = repository.publisher
    }
    
    public init<Storage: DataStorage, Source: DataSource>(storage: Storage, source: Source) where Storage.StoredItem == StoredItem, Storage.StorageError == StorageError, Storage.StorageReturn == StorageReturn, Source.OutputError == OutputError, Source.Parameter == Parameter, Source.Output == Output {
        _store = storage.store
        _publisher = source.publisher
    }

    public func publisher(parameter: QueryParameter?) -> AnyPublisher<Output, OutputError> {
        _publisher(parameter)
    }
    
    public func store(_ item: Output) -> AnyPublisher<StorageReturn, StorageError> {
        _store(item)
    }
}
