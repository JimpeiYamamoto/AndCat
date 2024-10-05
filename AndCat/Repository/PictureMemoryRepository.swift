import Foundation

public protocol PictureMemoryRepositoryType {
    func get(first: Date, last: Date) async -> [PictureMemory]
    func get(with category: Category) async -> [PictureMemory]
    func save(_ pictureMemory: PictureMemory) async
}
