import Foundation
import Combine

public class LSToPublisherMapper<Input>: Mapper {
    public typealias Input = Input
    public typealias Output = AnyPublisher<Input, Never>
    
    public func map(_ input: Input) -> Output {
        Just(input).eraseToAnyPublisher()
    }
}
