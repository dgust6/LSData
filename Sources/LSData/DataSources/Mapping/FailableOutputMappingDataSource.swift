import Foundation
import Combine

open class FailableOutputMappingDataSource<DS: DataSource, M: FailableMapper>: DataSource where DS.Output == M.Input {
    
    public typealias Output = M.Output
    public typealias OutputError = ErrorUnion<DS.OutputError, M.MappingError>
    
    public let dataSource: DS
    public let mapper: M
    
    public init(mapper: M, dataSource: DS) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
    
    open func publisher(parameter: DS.Parameter) -> AnyPublisher<M.Output, ErrorUnion<DS.OutputError, M.MappingError>> {
        dataSource.publisher(parameter: parameter)
            .tryMap { input in
                let output = self.mapper.map(input)
                switch output {
                case .success(let out):
                    return out
                case .failure(let error):
                    throw error
                }
            }
            .mapError { error -> ErrorUnion<DS.OutputError, M.MappingError> in
                if let outputError = error as? DS.OutputError {
                    return ErrorUnion<DS.OutputError, M.MappingError>(firstError: outputError)
                } else if let mappingError = error as? M.MappingError {
                    return ErrorUnion<DS.OutputError, M.MappingError>(secondError: mappingError)
                } else {
                    fatalError()
                }
            }
            .eraseToAnyPublisher()
    }
}

extension DataSource {
    func failableMap<M: FailableMapper>(with mapper: M) -> FailableOutputMappingDataSource<Self, M> {
        FailableOutputMappingDataSource(mapper: mapper, dataSource: self)
    }
}
