import Foundation
import Combine

open class LSRefreshableDataSource<T>: DataSource where T: DataSource {

    open var autoRefresh: Bool
    open var parameter: T.Parameter
    
    private let dataSource: T
    private var isRefreshing = false
    private let subject = CurrentValueSubject<T.Output?, T.OutputError>(nil)
    private var cancelBag = Set<AnyCancellable>()

    public init(dataSource: T, autoRefresh: Bool = false, parameter: T.Parameter) {
        self.dataSource = dataSource
        self.autoRefresh = autoRefresh
        self.parameter = parameter
    }
    
    open func refresh(with parameter: T.Parameter? = nil) {
        guard !isRefreshing else { return }
        isRefreshing = true
        dataSource.publisher(parameter: parameter ?? self.parameter)
            .first()
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                self.subject.send($0)
                self.isRefreshing = false
            })
            .store(in: &cancelBag)
        
    }

    open func publisher(parameter: Void) -> AnyPublisher<T.Output, T.OutputError> {
        if autoRefresh {
            refresh(with: self.parameter)
        }
        return subject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

public extension DataSource {
    func refreshable(autoRefresh: Bool = true, parameter: Parameter) -> LSRefreshableDataSource<Self> {
        LSRefreshableDataSource(dataSource: self, autoRefresh: autoRefresh, parameter: parameter)
    }
}

public extension LSRefreshableDataSource where T.Parameter == Optional<Any> {
    func refresh() {
        refresh(with: nil)
    }
    
    convenience init(dataSource: T, autoRefresh: Bool = true) {
        self.init(dataSource: dataSource, autoRefresh: autoRefresh, parameter: nil)
    }
}

public extension DataSource where Parameter == Optional<Any>  {
    func refreshable(autoRefresh: Bool = false) -> LSRefreshableDataSource<Self> {
        refreshable(autoRefresh: autoRefresh, parameter: nil)
    }
}

public extension LSRefreshableDataSource where T.Parameter == Void {
    func refresh() {
        refresh(with: ())
    }
    
    convenience init(dataSource: T, autoRefresh: Bool = false) {
        self.init(dataSource: dataSource, autoRefresh: autoRefresh, parameter: ())
    }
}

public extension DataSource where Parameter == Void  {
    func refreshable(autoRefresh: Bool = false) -> LSRefreshableDataSource<Self> {
        refreshable(autoRefresh: autoRefresh, parameter: ())
    }
}
