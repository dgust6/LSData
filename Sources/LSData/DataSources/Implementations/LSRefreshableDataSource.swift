import Foundation
import Combine

public class LSRefreshableDataSource<T>: DataSource where T: DataSource {

    public var autoRefresh: Bool
    public var parameter: T.Parameter
    
    private let dataSource: T
    private var isRefreshing = false
    private let subject = CurrentValueSubject<T.Output?, T.OutputError>(nil)
    private var cancelBag = Set<AnyCancellable>()

    public init(dataSource: T, autoRefresh: Bool = true, parameter: T.Parameter) {
        self.dataSource = dataSource
        self.autoRefresh = autoRefresh
        self.parameter = parameter
    }
    
    public func refresh(with parameter: T.Parameter) {
        guard !isRefreshing else { return }
        isRefreshing = true
        dataSource.publisher(parameter: parameter)
            .prefix(1)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                self.subject.send($0)
                self.isRefreshing = false
            })
            .store(in: &cancelBag)
        
    }

    public func publisher(parameter: T.Parameter) -> AnyPublisher<T.Output, T.OutputError> {
        if autoRefresh {
            refresh(with: parameter)
        }
        return subject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

extension DataSource {
    public func refreshable(autoRefresh: Bool = true, parameter: Parameter) -> LSRefreshableDataSource<Self> {
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

extension DataSource where Parameter == Optional<Any>  {
    public func refreshable(autoRefresh: Bool = true) -> LSRefreshableDataSource<Self> {
        refreshable(autoRefresh: autoRefresh, parameter: nil)
    }
}

extension LSRefreshableDataSource where T.Parameter == Void {
    func refresh() {
        refresh(with: ())
    }
    
    convenience init(dataSource: T, autoRefresh: Bool = true) {
        self.init(dataSource: dataSource, autoRefresh: autoRefresh, parameter: ())
    }
}

extension DataSource where Parameter == Void  {
    public func refreshable(autoRefresh: Bool = true) -> LSRefreshableDataSource<Self> {
        refreshable(autoRefresh: autoRefresh, parameter: ())
    }
}
