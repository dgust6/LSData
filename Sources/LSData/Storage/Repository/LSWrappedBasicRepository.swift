import Foundation
import Combine

open class LSWrappedBasicRepository<Source: DataSource, Storage: DataStorage>: DataBasicRepository where Storage.StoredItem == Source.Output {

    public typealias StoredItem = Storage.StoredItem
    public typealias StorageReturn = Storage.StorageReturn
    public typealias OutputError = Source.OutputError
    public typealias Parameter = Source.Parameter
    public typealias Output = Source.Output

    
    private let source: Source
    private let storage: Storage
    
    public init(source: Source, storage: Storage) {
        self.source = source
        self.storage = storage
    }
    
    open func store(_ item: StoredItem) -> StorageReturn {
        storage.store(item)
    }
    
    open func publisher(parameter: Parameter) -> AnyPublisher<Output, OutputError> {
        source.publisher(parameter: parameter)
    }
}
