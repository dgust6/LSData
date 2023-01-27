import Foundation
import Combine

open class ErrorMappingDataSource<DS: DataSource, M: Mapper>: DataSource where DS.OutputError == M.Input, M.Output: Error {
    
    public typealias OutputError = M.Output
    
    public let dataSource: DS
    public let mapper: M
    
    public init(mapper: M, dataSource: DS) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
    
    open func publisher(parameter: DS.Parameter) -> AnyPublisher<DS.Output, M.Output> {
        dataSource.publisher(parameter: parameter)
            .mapError(mapper.map)
            .eraseToAnyPublisher()
    }
}

public extension DataSource {
    func errorMap<M: Mapper>(with mapper: M) -> ErrorMappingDataSource<Self, M> where M.Input == Self.OutputError, M.Output: Error  {
        ErrorMappingDataSource(mapper: mapper, dataSource: self)
    }
    
    func errorMap<T: Error>(map: @escaping (OutputError) -> T) -> ErrorMappingDataSource<Self, GenericMapper<OutputError, T>> {
        errorMap(with: GenericMapper(map))
    }
}
