import Foundation
import Combine

open class LSPublisherDataSource<P: Publisher>: DataSource {
    
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
    func asDataSource() -> LSPublisherDataSource<Self> {
        LSPublisherDataSource(publisher: self)
    }
}
