import Foundation
import Combine

/// `DataSource` created by wrapping Combine's `Publisher`.
open class PublisherDataSource<P: Publisher>: DataSource {
    
    public typealias Output = P.Output
    public typealias OutputError = P.Failure
    public typealias Parameter = Void
    
    private let internalPublisher: P
    
    public init(publisher: P) {
        self.internalPublisher = publisher
    }
    
    open func publisher(parameter: Void) -> AnyPublisher<Output, OutputError> {
        internalPublisher.eraseToAnyPublisher()
    }
}

public extension Publisher {
    
    /// Creates LSData `DataSource` from this publisher.
    func asDataSource() -> PublisherDataSource<Self> {
        PublisherDataSource(publisher: self)
    }
}
