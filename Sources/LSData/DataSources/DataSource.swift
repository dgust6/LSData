import Foundation
import Combine

/// Abstracted and generic source of data.
///
/// Defining and core protocol of LSData, followed by `DataStorage` and `DeletableStorage`.
/// Functionality is similar to `Publisher` in Combine (or `Observable` in RxSwit) but with added parameter.
/// This optional (can be `Void`) parameter enables us to query the data source with supported queries and this way handle any use-case such as CoreData data source or Network data source.
public protocol DataSource {
    
    /// Output type
    associatedtype Output
    
    /// Parameter type. This can be `Optional` or `Void` if data source does not support parameters/queries.
    associatedtype Parameter = Void
    
    /// Error type
    associatedtype OutputError: Error = Error
    
    /// Returns `AnyPublisher` of the specified `DataSource`, queried by `parameter`
    func publisher(parameter: Parameter) -> AnyPublisher<Output, OutputError>
}

public extension DataSource {
    
    /// Type erases the `DataSource` to `LSAnyDataSource`.
    func erase() -> AnyDataSource<Output, Parameter, OutputError> {
        AnyDataSource(dataSource: self)
    }
}

public extension DataSource where Parameter == Void {
    func publisher() -> AnyPublisher<Output, OutputError> {
        publisher(parameter: ())
    }
}

public extension DataSource where Parameter == Optional<Any> {
    func publisher() -> AnyPublisher<Output, OutputError> {
        publisher(parameter: nil)
    }
}

public extension DataSource where Parameter == Array<Any> {
    func publisher() -> AnyPublisher<Output, OutputError> {
        publisher(parameter: [])
    }
}

/// Type erased `DataSource`
public class AnyDataSource<Output, QueryParameter, OutputError>: DataSource where OutputError: Error {

    public typealias Output = Output
    public typealias Parameter = QueryParameter
    public typealias OutputError = OutputError
    
    private let _publisher: ((QueryParameter) -> AnyPublisher<Output, OutputError>)
    
    public init<DS: DataSource>(dataSource: DS) where DS.Output == Output, DS.Parameter == QueryParameter, DS.OutputError == OutputError {
        _publisher = dataSource.publisher
    }
    
    public func publisher(parameter: Parameter) -> AnyPublisher<Output, OutputError> {
        _publisher(parameter)
    }
}
