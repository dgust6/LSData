import Foundation

/// `Mapper` which maps input to array.
///
/// For example, 1 will be mapped to [1].
public class ToArrayMapper<Input>: Mapper {
    public typealias Input = Input
    public typealias Output = [Input]
    
    public init() {}
    
    public func map(_ input: Input) -> [Input] {
        [input]
    }
}
