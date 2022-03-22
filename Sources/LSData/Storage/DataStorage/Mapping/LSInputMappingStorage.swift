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
    
    open func store(_ item: M.Input) -> Storage.StorageReturn {
        storage.store(mapper.map(item))
    }
}

public extension DataStorage {
    func itemMap<M: Mapper>(with mapper: M) -> LSInputMappingDataStorage<Self, M> where Self.StoredItem == M.Output {
        LSInputMappingDataStorage(mapper: mapper, storage: self)
    }
    
    func itemMap<MapIn>(map: @escaping (MapIn) -> Self.StoredItem) -> LSInputMappingDataStorage<Self, LSGenericMapper<MapIn, Self.StoredItem>> {
        itemMap(with: LSGenericMapper(map))
    }
}
