import Foundation
import Combine

open class ParameterMappingDataSource<DS: DataSource, M: Mapper>: DataSource where DS.Parameter == M.Output {

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
    func paramMap<M: Mapper>(with mapper: M) -> ParameterMappingDataSource<Self, M> where M.Output == Self.Parameter  {
        ParameterMappingDataSource(mapper: mapper, dataSource: self)
    }
    
    func paramMap<T>(map: @escaping (T) -> Parameter) -> ParameterMappingDataSource<Self, GenericMapper<T, Parameter>> {
        paramMap(with: GenericMapper(map))
    }
    
    func onInput(_ handler: @escaping (Parameter) -> Void) -> ParameterMappingDataSource<Self, GenericMapper<Parameter, Parameter>> {
        paramMap() { input in
            handler(input)
            return input
        }
    }
}
