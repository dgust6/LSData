import Foundation

public protocol FailableMapper<Input, Output, MappingError> {
    
    associatedtype Input
    associatedtype Output
    associatedtype MappingError: Error
    
    func map(_ input: Input) -> Result<Output, MappingError>
}
