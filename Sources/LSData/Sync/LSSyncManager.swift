import Foundation
import Combine

public enum StorageDeallocationError: Error {
    case deallocated
}

public protocol SyncManager {
    func sync()
}

public class LSSyncManager<Source: DataSource, Storage: DataStorage>: SyncManager where Source.Output == Storage.StoredItem {

    public var parameter: Source.Parameter?

    private let dataSource: Source
    private let dataStorage: Storage

    private var cancelBag = Set<AnyCancellable>()

    public init(dataSource: Source, dataStorage: Storage, parameter: Source.Parameter? = nil) {
        self.dataSource = dataSource
        self.dataStorage = dataStorage
        self.parameter = parameter
    }

    public func sync() {
        dataSource
            .store(to: dataStorage, parameter: parameter)
            .sink()
            .store(in: &cancelBag)
    }
}

extension DataSource {
    
    public func syncManager<Storage: DataStorage>(with storage: Storage, parameter: Parameter? = nil) -> LSSyncManager<Self, Storage> where Output == Storage.StoredItem {
        LSSyncManager(dataSource: self, dataStorage: storage, parameter: parameter)
    }
    
    public func store<Storage: DataStorage>(to storage: Storage, parameter: Parameter? = nil, count: Int = 1) -> AnyPublisher<Storage.StorageReturn, Error> where Output == Storage.StoredItem {
        
        weak var weakStorage = storage as AnyObject
        
        let publisher = count == 0 ?
            publisher(parameter: parameter).eraseToAnyPublisher()
            : publisher(parameter: parameter).prefix(count).eraseToAnyPublisher()
        
        return publisher
            .tryMap { item -> AnyPublisher<Storage.StorageReturn, Error> in
                guard let storage = weakStorage as? Storage else { throw StorageDeallocationError.deallocated }
                return storage
                    .store(item)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
