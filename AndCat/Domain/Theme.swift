import Foundation

// SwiftDataで保存するために、Codableにする。
public struct Theme: Codable {
    public let category: Category
    public let question: String
    public let answer: String
}
