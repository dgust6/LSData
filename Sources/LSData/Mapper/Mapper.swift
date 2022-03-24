import Foundation

/// Generic mapping protocol.
///
/// Enables mapping of specified `Input` into specified `Output`
public protocol Mapper {
    
    associatedtype Input
    associatedtype Output
    
    /// Maps `Input` type into `Output` type.
    func map(_ input: Input) -> Output
}

public extension Mapper {
    
    /// Type erases the `Mapper` to `LSAnyMapper`.
    func erase() -> LSAnyMapper<Input, Output> {
        LSAnyMapper(mapper: self)
    }
}

/// Type erased `Mapper`.
public class LSAnyMapper<Input, Output>: Mapper {

    public typealias Input = Input
    public typealias Output = Output
    
    private let _map: ((Input) -> Output)
    
    public init<M: Mapper>(mapper: M) where M.Output == Output, M.Input == Input {
        _map = mapper.map
    }
    
    public func map(_ input: Input) -> Output {
        _map(input)
    }
}
