import Foundation
import Combine

open class LSPublisherModifyingDataSource<Output, OutputError: Error, DS: DataSource>: DataSource {
    
    public typealias Parameter = DS.Parameter
    public typealias Output = Output
    public typealias OutputError = OutputError
    
    public typealias Modifier = (AnyPublisher<DS.Output, DS.OutputError>) -> AnyPublisher<Output, OutputError>
    
    public let modifyer: Modifier
    public let dataSource: DS
    
    public init(dataSource: DS, modifier: @escaping Modifier) {
        self.modifyer = modifier
        self.dataSource = dataSource
    }
    
    open func publisher(parameter: Parameter) -> AnyPublisher<Output, OutputError> {
        modifyer(dataSource.publisher(parameter: parameter))
    }
}

public extension DataSource {
    func modifyPublisher<NewOutput, NewOutputError: Error>(modifier: @escaping (AnyPublisher<Output, OutputError>) -> AnyPublisher<NewOutput, NewOutputError>) -> LSPublisherModifyingDataSource<NewOutput, NewOutputError,Self> {
        LSPublisherModifyingDataSource(dataSource: self, modifier: modifier)
    }
}
