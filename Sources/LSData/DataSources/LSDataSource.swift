import Foundation
import Combine

public protocol DataSource {
    
    associatedtype Output
    associatedtype Parameter = Void
    associatedtype OutputError: Error = Error
    
    func publisher(parameter: Parameter?) -> AnyPublisher<Output, OutputError>
    func publisher() -> AnyPublisher<Output, OutputError>
    func erase() -> LSAnyDataSource<Output, Parameter, OutputError>
}

public extension DataSource {
    func publisher() -> AnyPublisher<Output, OutputError> {
        publisher(parameter: nil)
    }
    
    func erase() -> LSAnyDataSource<Output, Parameter, OutputError> {
        LSAnyDataSource(dataSource: self)
    }
}

public class LSAnyDataSource<Output, QueryParameter, OutputError>: DataSource where OutputError: Error {

    public typealias Output = Output
    public typealias Parameter = QueryParameter
    public typealias OutputError = OutputError
    
    private let _publisher: ((QueryParameter?) -> AnyPublisher<Output, OutputError>)
    
    public init<DS: DataSource>(dataSource: DS) where DS.Output == Output, DS.Parameter == QueryParameter, DS.OutputError == OutputError {
        _publisher = dataSource.publisher
    }
    
    public func publisher(parameter: Parameter?) -> AnyPublisher<Output, OutputError> {
        _publisher(parameter)
    }
}
