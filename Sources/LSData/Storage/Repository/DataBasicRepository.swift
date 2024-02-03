import Foundation
import Combine

public protocol DataBasicRepository: DataSource, DataStorage, DeletableStorage where Output == StoredItem?, DeletableItem == StoredItem {

}
