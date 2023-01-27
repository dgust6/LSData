import Foundation
import Combine

/// `Mapper` which maps input to the Combine's `Just` to create a `Publisher`.
///
/// For example, 1 will be mapped to Just(1).
public class ToPublisherMapper<Input>: Mapper {
    
    public typealias Input = Input
    public typealias Output = AnyPublisher<Input, Never>
    
    public init() {}
    
    public func map(_ input: Input) -> Output {
        Just(input).eraseToAnyPublisher()
    }
}
