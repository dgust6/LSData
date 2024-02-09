import Foundation
import Combine

open class OutputMappingDataSource<DS: DataSource, M: Mapper>: DataSource where DS.Output == M.Input {
    
    public typealias Output = M.Output
    
    public let dataSource: DS
    public let mapper: M
    
    public init(mapper: M, dataSource: DS) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
    
    open func publisher(parameter: DS.Parameter) -> AnyPublisher<M.Output, DS.OutputError> {
        dataSource.publisher(parameter: parameter)
            .map { self.mapper.map($0) }
            .eraseToAnyPublisher()
    }
}

public extension DataSource {
    func outMap<T>(map: @escaping (Output) -> T) -> OutputMappingDataSource<Self, GenericMapper<Output, T>> {
        outMap(with: GenericMapper(map))
    }
    
    func outMap<M: Mapper>(with mapper: M) -> OutputMappingDataSource<Self, M> {
        OutputMappingDataSource(mapper: mapper, dataSource: self)
    }
    
    func onOutput(_ handler: @escaping (Output) -> Void) -> OutputMappingDataSource<Self, GenericMapper<Output, Output>> {
        outMap() { output in
            handler(output)
            return output
        }
    }
}
