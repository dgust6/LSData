import Foundation

public class LSToArrayMapper<Input>: Mapper {
    public typealias Input = Input
    public typealias Output = [Input]
    
    public func map(_ input: Input) -> [Input] {
        [input]
    }
}
