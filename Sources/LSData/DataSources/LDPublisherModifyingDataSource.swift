import Foundation
import Combine

class LDPublisherModifyingDataSource<Output, OutputError: Error, DS: DataSource>: DataSource {
    
    typealias Parameter = DS.Parameter
    typealias Output = Output
    typealias OutputError = OutputError
    
    typealias Modifier = (AnyPublisher<DS.Output, DS.OutputError>) -> AnyPublisher<Output, OutputError>
    
    let modifyer: Modifier
    let dataSource: DS
    
    init(dataSource: DS, modifier: @escaping Modifier) {
        self.modifyer = modifier
        self.dataSource = dataSource
    }
    
    func publisher(parameter: Parameter?) -> AnyPublisher<Output, OutputError> {
        modifyer(dataSource.publisher(parameter: parameter))
    }
    
    func publisher() -> AnyPublisher<Output, OutputError> {
        modifyer(dataSource.publisher())
    }
}

extension DataSource {
    
    func modifyPublisher<NewOutput, NewOutputError: Error>(modifier: @escaping (AnyPublisher<Output, OutputError>) -> AnyPublisher<NewOutput, NewOutputError>) -> LDPublisherModifyingDataSource<NewOutput, NewOutputError,Self> {
        LDPublisherModifyingDataSource(dataSource: self, modifier: modifier)
    }
}
