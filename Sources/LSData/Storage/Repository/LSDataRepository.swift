import Foundation

public protocol DataRepository: DataSource, DataGeneralStorage, Deletable where Output == StoredItem, Output == DeletableItem {

}
