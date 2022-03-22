import Foundation
import Combine

public protocol SyncManager {
    func sync()
}

open class LSSyncManager<Source: DataSource, Storage: DataStorage>: SyncManager where Source.Output == Storage.StoredItem, Storage.StorageReturn: Publisher {

    open var parameter: Source.Parameter
    open var syncPublisher: AnyPublisher<Source.Output, Source.OutputError> {
        dataSource.publisher(parameter: ())
    }

    private let dataSource: LSRefreshableDataSource<Source>
    private let dataStorage: Storage

    private var cancelBag = Set<AnyCancellable>()

    public init(dataSource: Source, dataStorage: Storage, parameter: Source.Parameter) {
        self.dataSource = dataSource.refreshable(parameter: parameter)
        self.dataStorage = dataStorage
        self.parameter = parameter
        
        self.dataSource
            .store(to: dataStorage, parameter: (), count: 0)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancelBag)
    }

    open func sync() {
        dataSource.refresh()
    }
}

public extension DataSource {
    func syncManager<Storage: DataStorage>(with storage: Storage, parameter: Parameter) -> LSSyncManager<Self, Storage> where Output == Storage.StoredItem {
        LSSyncManager(dataSource: self, dataStorage: storage, parameter: parameter)
    }
}
