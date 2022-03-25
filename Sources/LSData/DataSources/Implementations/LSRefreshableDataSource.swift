import Foundation
import Combine

/// `DataSource` which enables refreshing of it's internal publisher.
///
/// Common usage can be wrapping an existing `DataSource` such as one triggering network requests and refreshing the data on call of the `refresh` method.
/// Since Combine's `CurrentValueSubject` is used internally, new subscribers to `publisher` method are immediately given the last result of refresh (if it was refreshed before).
open class LSRefreshableDataSource<T>: DataSource where T: DataSource {

    /// If set to `true`, calls on `publisher` method will automatically trigger `refresh`.
    /// Default is `true`
    open var autoRefresh: Bool
    
    /// Denotes if publishing is terminated by error.
    /// Default is `false`.
    open var finishOnError: Bool
    
    /// Refresh parameter, passed to the internal `dataSource`.
    open var parameter: T.Parameter
    
    private let dataSource: T
    private var isRefreshing = false
    private let subject = CurrentValueSubject<T.Output?, T.OutputError>(nil)
    private var cancelBag = Set<AnyCancellable>()

    public init(dataSource: T, autoRefresh: Bool = false, parameter: T.Parameter, finishOnError: Bool = false) {
        self.dataSource = dataSource
        self.autoRefresh = autoRefresh
        self.parameter = parameter
        self.finishOnError = finishOnError
    }
    
    /// Refreshes the internal `dataSource` by subscribing to it and taking only the first element, terminating the subscription afterwards.
    /// If `finishOnError` is set to `true`, internal `publisher` will complete with error.
    open func refresh(with parameter: T.Parameter? = nil) {
        guard !isRefreshing else { return }
        isRefreshing = true
        dataSource.publisher(parameter: parameter ?? self.parameter)
            .first()
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    if self?.finishOnError == true {
                        self?.subject.send(completion: .failure(error))
                        return
                    }
                case .finished:
                    self?.isRefreshing = false
                    return
                }
                self?.isRefreshing = false
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
    
    /// Creates `LSRefreshableDataSource` from this `DataSource`.
    func refreshable(autoRefresh: Bool = false, parameter: Parameter) -> LSRefreshableDataSource<Self> {
        LSRefreshableDataSource(dataSource: self, autoRefresh: autoRefresh, parameter: parameter)
    }
}

public extension LSRefreshableDataSource where T.Parameter == Optional<Any> {
    func refresh() {
        refresh(with: nil)
    }
    
    convenience init(dataSource: T, autoRefresh: Bool = false) {
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
