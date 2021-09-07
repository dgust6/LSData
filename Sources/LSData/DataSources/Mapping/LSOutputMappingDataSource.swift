import Foundation
import Combine

open class LSOutputMappingDataSource<DS: DataSource, M: Mapper>: DataSource where DS.Output == M.Input {
    
    public typealias Output = M.Output
    public typealias OutputError = DS.OutputError
    
    public let dataSource: DS
    public let mapper: M
    
    public init(mapper: M, dataSource: DS) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
    
    public func publisher(parameter: DS.Parameter?) -> AnyPublisher<M.Output, DS.OutputError> {
        dataSource.publisher(parameter: parameter)
            .map(mapper.map)
            .eraseToAnyPublisher()
    }
    
    public func erase() -> LSAnyDataSource<Output, Parameter, OutputError> {
        LSAnyDataSource(dataSource: self)
    }
}

extension DataSource {
    public func outMap<T, M: Mapper>(with mapper: M) -> LSOutputMappingDataSource<Self, M> where M.Input == Output, M.Output == T {
        LSOutputMappingDataSource(mapper: mapper, dataSource: self)
    }
    
    public func outMap<T>(map: @escaping (Output) -> T) -> LSOutputMappingDataSource<Self, LSGenericMapper<Output, T>> {
        outMap(with: LSGenericMapper(map))
    }
}
