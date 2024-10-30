import Foundation

// SwiftDataで保存するために、Codableにする。
public struct Theme: Codable {
    public let category: Category
    public let question: String
    public let answer: String

    // TODO: ランダムで決定 or フェッチで決定するように修正して削除
    static let initialTheme = Theme(
        category: .playing("#猫が落ちてきました"),
        question: "あなたは今どんな気分",
        answer: ""
    )
}

