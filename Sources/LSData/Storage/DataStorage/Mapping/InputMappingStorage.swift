import Foundation
import Combine

open class InputMappingDataStorage<Storage: DataStorage, M: Mapper>: DataStorage where Storage.StoredItem == M.Output {
    
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
    
    /// Maps data storage input parameter type.
    func itemMap<M: Mapper>(with mapper: M) -> InputMappingDataStorage<Self, M> where Self.StoredItem == M.Output {
        InputMappingDataStorage(mapper: mapper, storage: self)
    }
    
    /// Maps data storage input parameter type.
    func itemMap<MapIn>(map: @escaping (MapIn) -> Self.StoredItem) -> InputMappingDataStorage<Self, GenericMapper<MapIn, Self.StoredItem>> {
        itemMap(with: GenericMapper(map))
    }
}
