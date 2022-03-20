import Foundation
import Combine

open class LSOutputMappingDataStorage<Storage: DataStorage, M: Mapper>: DataStorage where M.Input == Storage.StorageReturn {

    public typealias StoredItem = Storage.StoredItem
    
    public let storage: Storage
    public let mapper: M
    
    public init(mapper: M, storage: Storage) {
        self.storage = storage
        self.mapper = mapper
    }
    
    public func store(_ item: StoredItem) -> M.Output {
        mapper.map(storage.store(item))
    }
}

extension DataStorage {
    public func resultMap<M: Mapper>(with mapper: M) -> LSOutputMappingDataStorage<Self, M> where M.Input == Self.StorageReturn {
        LSOutputMappingDataStorage(mapper: mapper, storage: self)
    }
    
    public func resultMap<T>(map: @escaping (Self.StorageReturn) -> T) -> LSOutputMappingDataStorage<Self, LSGenericMapper<Self.StorageReturn, T>> {
        resultMap(with: LSGenericMapper(map))
    }
}
