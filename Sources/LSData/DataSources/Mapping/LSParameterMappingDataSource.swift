import Foundation
import Combine

open class LSParameterMappingDataSource<DS: DataSource, M: Mapper>: DataSource where DS.Parameter == M.Output {

    public typealias Parameter = M.Input
    public typealias Output = DS.Output
    
    public let dataSource: DS
    public let mapper: M
    
    public init(mapper: M, dataSource: DS) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
    
    open func publisher(parameter: M.Input) -> AnyPublisher<DS.Output, DS.OutputError> {
        dataSource.publisher(parameter: mapper.map(parameter))
            .eraseToAnyPublisher()
    }
}

public extension DataSource {
    func paramMap<M: Mapper>(with mapper: M) -> LSParameterMappingDataSource<Self, M> where M.Output == Self.Parameter  {
        LSParameterMappingDataSource(mapper: mapper, dataSource: self)
    }
    
    
    func paramMap<T>(map: @escaping (T) -> Parameter) -> LSParameterMappingDataSource<Self, LSGenericMapper<T, Parameter>> {
        paramMap(with: LSGenericMapper(map))
    }
}
