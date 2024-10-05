import Foundation

// SwiftDataで保存するために、Codableにする。
public enum Category: Codable {
    case eating(String)
    case sleeping(String)
    case playing(String)
    case trouble(String)
    case selfie(String)
    case history(String)
}
