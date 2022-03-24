import Foundation

/// `Mapper` which maps input to array.
///
/// For example, 1 will be mapped to [1].
public class LSToArrayMapper<Input>: Mapper {
    public typealias Input = Input
    public typealias Output = [Input]
    
    public func map(_ input: Input) -> [Input] {
        [input]
    }
}
