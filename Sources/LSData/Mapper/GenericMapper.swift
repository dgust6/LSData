import Foundation

/// Generic `Mapper` created with supplied map method.
public class GenericMapper<I, O>: Mapper {
    
    public typealias Input = I
    public typealias Output = O
    
    public typealias MapMethod = ((I) -> O)
    
    public var mapMethod: MapMethod
    
    public init(_ map: @escaping MapMethod) {
        mapMethod = map
    }
    
    public func map(_ input: I) -> O {
        mapMethod(input)
    }
}
