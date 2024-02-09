import Foundation

public struct ErrorUnion<First: Error, Second: Error>: Error {
    
    public typealias First = First
    public typealias Second = Second
    
    public let firstError: First?
    public let secondError: Second?
    
    public var error: Error {
        firstError ?? secondError!
    }
    
    public var concreteError: Error {
        if let error = error as? ErrorUnion {
            return error.concreteError
        } else {
            return error
        }
    }
    
    public init(firstError: First) {
        self.firstError = firstError
        self.secondError = nil
    }
    
    public init(secondError: Second) {
        self.firstError = nil
        self.secondError = secondError
    }
}
