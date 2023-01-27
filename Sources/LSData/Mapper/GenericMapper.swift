import Foundation

/// Generic `Mapper` created with supplied map method.
public class GenericMapper<In, Out>: Mapper {
    
    public typealias Input = In
    public typealias Output = Out
    
    public typealias MapMethod = ((In) -> Out)
    
    public var mapMethod: MapMethod
    
    public init(_ map: @escaping MapMethod) {
        mapMethod = map
    }
    
    public func map(_ input: In) -> Out {
        mapMethod(input)
    }
}
