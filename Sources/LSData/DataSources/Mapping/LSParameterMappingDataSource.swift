import Foundation
import Combine

open class LSParameterMappingDataSource<DS: DataSource, M: Mapper, Param>: DataSource where DS.Parameter == M.Output, M.Input == Param? {

    public typealias Parameter = Param
    public typealias Output = DS.Output
    
    public let dataSource: DS
    public let mapper: M
    
    public init(mapper: M, dataSource: DS) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
    
    public func publisher(parameter: Param?) -> AnyPublisher<DS.Output, DS.OutputError> {
        dataSource.publisher(parameter: mapper.map(parameter))
            .eraseToAnyPublisher()
    }
}

extension DataSource {
    
    public func paramMap<M: Mapper, Param>(with mapper: M) -> LSParameterMappingDataSource<Self, M, Param> where M.Output == Self.Parameter  {
        LSParameterMappingDataSource(mapper: mapper, dataSource: self)
    }
    
    
    public func paramMap<T>(map: @escaping (T?) -> Parameter) -> LSParameterMappingDataSource<Self, LSGenericMapper<T?, Parameter>, Parameter> {
        paramMap(with: LSGenericMapper(map))
    }
}
