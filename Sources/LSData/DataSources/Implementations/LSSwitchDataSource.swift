import Foundation
import Combine

/// `DataSource` with two internal sources, switching from base source to second one on supplied `condition`.
///
/// Common use-cases would include querying one `DataSource` and if it's empty querying the other one.
/// For example, if CoreData is empty, query Network.
open class LSSwitchDataSource<DS1: DataSource, DS2: DataSource>: DataSource where DS2.Output == DS1.Output, DS1.Parameter == DS2.Parameter, DS1.OutputError == DS2.OutputError {
    
    public typealias Output = DS1.Output
    public typealias Parameter = DS1.Parameter
    public typealias OutputError = DS1.OutputError
    public typealias Condition = (Output) -> Bool
    
    /// Base `DataSource`, supplying data UNTIL specified `condition` (result is `false`) is met.
    private let baseSource: DS1
    
    /// Second `DataSource`, supplying data WHEN specified `condition` (result is `true`) is met.
    private let switchSource: DS2
    
    /// Condition triggered by each output of `baseSource`.
    /// `false` supplies data from `baseSource`, while `true` supplies data from `switchSource`.
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
    
    /// Supplies data from given `dataSource` instead, when supplied `condition` is met on output.
    ///
    /// Creates `LSSwitchDataSource`.
    func switchOnCondition<DS2: DataSource>(to dataSource: DS2, condition: @escaping (Output) -> Bool) -> LSSwitchDataSource<Self, DS2> where Self.Output == DS2.Output, Self.Output == DS2.OutputError, Self.Parameter == DS2.Parameter {
        LSSwitchDataSource<Self, DS2>(baseSource: self, switchSource: dataSource, condition: condition)
    }
}

public extension DataSource where Output: Collection {
    
    /// Supplies data from given `dataSource` when output of this `DataSource` is an empty array.
    ///
    /// Creates `LSSwitchDataSource`.
    func switchOnEmpty<DS2: DataSource>(to dataSource: DS2) -> LSSwitchDataSource<Self, DS2> where Self.Output == DS2.Output, Self.Output == DS2.OutputError, Self.Parameter == DS2.Parameter {
        LSSwitchDataSource<Self, DS2>(baseSource: self, switchSource: dataSource, condition: { $0.isEmpty })
    }
}
