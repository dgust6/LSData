import Foundation
import Combine

public class LSPublisherDataSource<P: Publisher>: DataSource {
    
    public typealias Output = P.Output
    public typealias OutputError = P.Failure
    public typealias Parameter = Void
    
    private let internalPublisher: P
    
    public init(publisher: P) {
        self.internalPublisher = publisher
    }
    
    public func publisher(parameter: Void) -> AnyPublisher<Output, OutputError> {
        internalPublisher.eraseToAnyPublisher()
    }
}

extension Publisher {
    public func asDataSource() -> LSPublisherDataSource<Self> {
        LSPublisherDataSource(publisher: self)
    }
}
