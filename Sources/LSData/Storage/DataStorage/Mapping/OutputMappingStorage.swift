import Foundation
import Combine

open class OutputMappingDataStorage<Storage: DataStorage, M: Mapper>: DataStorage where M.Input == Storage.StorageReturn {

    public typealias StoredItem = Storage.StoredItem
    
    public let storage: Storage
    public let mapper: M
    
    public init(mapper: M, storage: Storage) {
        self.storage = storage
        self.mapper = mapper
    }
    
    open func store(_ item: StoredItem) -> M.Output {
        mapper.map(storage.store(item))
    }
}

public extension DataStorage {
    func resultMap<M: Mapper>(with mapper: M) -> OutputMappingDataStorage<Self, M> where M.Input == Self.StorageReturn {
        OutputMappingDataStorage(mapper: mapper, storage: self)
    }
    
    func resultMap<T>(map: @escaping (Self.StorageReturn) -> T) -> OutputMappingDataStorage<Self, GenericMapper<Self.StorageReturn, T>> {
        resultMap(with: GenericMapper(map))
    }
}
