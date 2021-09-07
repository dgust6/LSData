import Foundation
import Combine

open class LSInputMappingDataStorage<Storage: DataStorage, M: Mapper>: DataStorage where Storage.StoredItem == M.Output {
    
    public typealias StoredItem = M.Input
    
    public let storage: Storage
    public let mapper: M
    
    public init(mapper: M, storage: Storage) {
        self.storage = storage
        self.mapper = mapper
    }
    
    public func store(_ item: M.Input) -> AnyPublisher<Storage.StorageReturn, Storage.StorageError> {
        storage.store(mapper.map(item))
    }
}

extension DataStorage {
    public func itemMap<M: Mapper>(with mapper: M) -> LSInputMappingDataStorage<Self, M> where Self.StoredItem == M.Output {
        LSInputMappingDataStorage(mapper: mapper, storage: self)
    }
    
    public func itemMap<MapIn>(map: @escaping (MapIn) -> Self.StoredItem) -> LSInputMappingDataStorage<Self, LSGenericMapper<MapIn, Self.StoredItem>> {
        itemMap(with: LSGenericMapper(map))
    }
}