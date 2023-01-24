import Foundation
import Combine

public enum RefreshBlockType {
    case none // refresh is not blocked
    case regular // refresh is blocked while there is another one running
    case cacheLast // like regular but last refresh called while blocked is executed after unblock
}

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

    open var refreshBlockType: RefreshBlockType
    
    /// Refresh parameter, passed to the internal `dataSource`.
    open var parameter: T.Parameter
    
    /// Publishes all errors.
    /// This may be useful if `finishOnError` is set to `false` and you wish to see if there are errors happening
    open var errorPublisher: AnyPublisher<T.OutputError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private let dataSource: T
    private var isRefreshing = false {
        didSet {
            if refreshBlockType == .cacheLast && parameterCache.0 == true {
                let cache = parameterCache
                parameterCache = (false, nil)
                refresh(with: cache.1)
            }
        }
    }
    private let subject = CurrentValueSubject<T.Output?, T.OutputError>(nil)
    private let errorSubject = PassthroughSubject<T.OutputError, Never>()
    private var parameterCache: (Bool, T.Parameter?) = (false, nil)
    private var cancelBag = Set<AnyCancellable>()

    public init(dataSource: T, autoRefresh: Bool = false, parameter: T.Parameter, finishOnError: Bool = false, refreshBlockType: RefreshBlockType = .regular) {
        self.dataSource = dataSource
        self.autoRefresh = autoRefresh
        self.parameter = parameter
        self.finishOnError = finishOnError
        self.refreshBlockType = refreshBlockType
    }
    
    /// Refreshes the internal `dataSource` by subscribing to it and taking only the first element, terminating the subscription afterwards.
    /// If `finishOnError` is set to `true`, internal `publisher` will complete with error.
    open func refresh(with parameter: T.Parameter? = nil) {
        if isRefreshing && refreshBlockType != .none {
            parameterCache = (true, parameter)
            return
        }
        isRefreshing = true
        dataSource.publisher(parameter: parameter ?? self.parameter)
            .first()
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.errorSubject.send(error)
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

    open func publisher(parameter: Void = ()) -> AnyPublisher<T.Output, T.OutputError> {
        if autoRefresh {
            refresh(with: self.parameter)
        }
        return subject
            .compactMap { $0 }
            .eraseToAnyPublisher()
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

public extension DataSource {
    
    /// Creates `LSRefreshableDataSource` from this `DataSource`.
    func refreshable(autoRefresh: Bool = false, parameter: Parameter, finishOnError: Bool = false, refreshBlockType: RefreshBlockType = .regular) -> LSRefreshableDataSource<Self> {
        LSRefreshableDataSource(dataSource: self, autoRefresh: autoRefresh, parameter: parameter, finishOnError: finishOnError, refreshBlockType: refreshBlockType)
    }
}

public extension DataSource where Parameter == Optional<Any>  {
    
    /// Creates `LSRefreshableDataSource` from this `DataSource`.
    func refreshable(autoRefresh: Bool = false) -> LSRefreshableDataSource<Self> {
        refreshable(autoRefresh: autoRefresh, parameter: nil)
    }
}

public extension DataSource where Parameter == Void  {
    
    /// Creates `LSRefreshableDataSource` from this `DataSource`.
    func refreshable(autoRefresh: Bool = false) -> LSRefreshableDataSource<Self> {
        refreshable(autoRefresh: autoRefresh, parameter: ())
    }
}
