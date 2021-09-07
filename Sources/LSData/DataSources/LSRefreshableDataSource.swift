import Foundation
import Combine

public class LSRefreshableDataSource<T>: DataSource where T: DataSource {

    public var autoRefresh: Bool
    public var parameter: T.Parameter?
    
    private let dataSource: T
    private var isRefreshing = false
    private let subject = CurrentValueSubject<T.Output?, T.OutputError>(nil)
    private var cancelBag = Set<AnyCancellable>()

    public init(dataSource: T, autoRefresh: Bool = true, parameter: T.Parameter? = nil) {
        self.dataSource = dataSource
        self.autoRefresh = autoRefresh
        self.parameter = parameter
    }
    
    public func refresh(with parameter: T.Parameter? = nil) {
        guard !isRefreshing else { return }
        isRefreshing = true
        dataSource.publisher(parameter: parameter ?? self.parameter)
            .prefix(1)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                self.subject.send($0)
                self.isRefreshing = false
            })
            .store(in: &cancelBag)
        
    }

    public func publisher(parameter: T.Parameter? = nil) -> AnyPublisher<T.Output, T.OutputError> {
        if autoRefresh {
            refresh(with: parameter)
        }
        return subject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

extension DataSource {
    public func refreshable(autoRefresh: Bool = true, parameter: Parameter? = nil) -> LSRefreshableDataSource<Self> {
        LSRefreshableDataSource(dataSource: self, autoRefresh: autoRefresh, parameter: parameter)
    }
}
