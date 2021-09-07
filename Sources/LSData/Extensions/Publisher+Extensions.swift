import Foundation
import Combine

public extension Publisher {

    func sink() -> AnyCancellable {
        sink(receiveCompletion: { _ in
            
        }, receiveValue: { _ in
            
        })
    }
    
    func flatMapLatest<T: Publisher>(_ transform: @escaping (Self.Output) -> T) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
        map(transform).switchToLatest()
    }
}
