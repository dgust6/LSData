import Foundation

public protocol Mapper {
    associatedtype Input
    associatedtype Output
    
    func map(_ input: Input) -> Output
}

public extension Mapper {
    func erase() -> LSAnyMapper<Input, Output> {
        LSAnyMapper(mapper: self)
    }
}

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
