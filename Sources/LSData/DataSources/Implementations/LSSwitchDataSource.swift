import Foundation
import Combine

open class LSSwitchDataSource<DS1: DataSource, DS2: DataSource>: DataSource where DS2.Output == DS1.Output, DS1.Parameter == DS2.Parameter, DS1.OutputError == DS2.OutputError {
    
    public typealias Output = DS1.Output
    public typealias Parameter = DS1.Parameter
    public typealias OutputError = DS1.OutputError
    public typealias Condition = (Output) -> Bool
    
    private let baseSource: DS1
    private let switchSource: DS2
    private let condition: Condition
    
    public init(baseSource: DS1, switchSource: DS2, condition: @escaping Condition) {
        self.baseSource = baseSource
        self.switchSource = switchSource
        self.condition = condition
    }
    
    open func publisher(parameter: DS1.Parameter) -> AnyPublisher<DS1.Output, DS1.OutputError> {
        baseSource.publisher(parameter: parameter)
            .map { output -> AnyPublisher<DS1.Output, DS1.OutputError> in
                guard self.condition(output) else {
                    return self.switchSource.publisher(parameter: parameter)
                }
                return Just(output)
                    .setFailureType(to: OutputError.self)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

public extension DataSource {
    func switchOnCondition<DS2: DataSource>(to dataSource: DS2, condition: @escaping (Output) -> Bool) -> LSSwitchDataSource<Self, DS2> where Self.Output == DS2.Output, Self.Output == DS2.OutputError, Self.Parameter == DS2.Parameter {
        LSSwitchDataSource<Self, DS2>(baseSource: self, switchSource: dataSource, condition: condition)
    }
}

public extension DataSource where Output: Collection {
    func switchOnEmpty<DS2: DataSource>(to dataSource: DS2) -> LSSwitchDataSource<Self, DS2> where Self.Output == DS2.Output, Self.Output == DS2.OutputError, Self.Parameter == DS2.Parameter {
        LSSwitchDataSource<Self, DS2>(baseSource: self, switchSource: dataSource, condition: { $0.isEmpty })
    }
}
