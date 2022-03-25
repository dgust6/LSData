import Foundation

public protocol DataRepository: DataSource, DataGeneralStorage, DeletableStorage where Output == StoredItem, Output == DeletableItem { }
