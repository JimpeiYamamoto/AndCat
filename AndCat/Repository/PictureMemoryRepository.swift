import Foundation

public protocol PictureMemoryRepositoryType {
    func get(first: Date, last: Date) -> [PictureMemory]
    func get(with category: Category) -> [PictureMemory]
    func save(_ pictureMemory: PictureMemory)
}
