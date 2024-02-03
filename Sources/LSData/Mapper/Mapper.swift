import Foundation

/// Generic mapping protocol.
///
/// Enables mapping of specified `Input` into specified `Output`
public protocol Mapper<Input, Output> {
    
    associatedtype Input
    associatedtype Output
    
    /// Maps `Input` type into `Output` type.
    func map(_ input: Input) -> Output
}
