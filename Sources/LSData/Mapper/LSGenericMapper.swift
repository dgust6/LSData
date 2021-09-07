import Foundation

public class LSGenericMapper<In, Out>: Mapper {
    
    public typealias Input = In
    public typealias Output = Out
    
    public typealias MapMethod = ((In) -> Out)
    
    public var _map: MapMethod
    
    public init(_ map: @escaping MapMethod) {
        _map = map
    }
    
    public func map(_ input: In) -> Out {
        _map(input)
    }
}
