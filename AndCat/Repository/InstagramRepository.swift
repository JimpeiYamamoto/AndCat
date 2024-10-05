//
//  InstagramRepository.swift
//  AndCat
//
//  Created by KoichiroUeki on 2024/10/05.
//
import Foundation
import UIKit

public enum InstagramError: LocalizedError {
    case missingURLScheme
    case missingStickerImageData
    case couldNotOpenInstagram
}

public enum OptionsKey: String {
    case stickerImage = "com.instagram.sharedSticker.stickerImage"
    case backgroundImage = "com.instagram.sharedSticker.backgroundImage"
    case backgroundVideo = "com.instagram.sharedSticker.backgroundVideo"
    case backgroundTopColor = "com.instagram.sharedSticker.backgroundTopColor"
    case backgroundBottomColor = "com.instagram.sharedSticker.backgroundBottomColor"
    case contentURL = "com.instagram.sharedSticker.contentURL"
}

final class InstagramRepository {
    static let shared = InstagramRepository()
    private let appID = "654919228624777" // ここは「アプリID」に置き換える
    
    private var urlScheme: URL? {
        URL(string: "instagram-stories://share?source_application=\(appID)")
    }
    
    @MainActor
    func share(
        stickerImage: UIImage,
        backgroundTopColor: String,
        backgroundBottomColor: String
    ) async throws {
        guard let urlScheme else {
            throw InstagramError.missingURLScheme
        }
        var items: [String: Any] = [:]
        guard let stickerData = stickerImage.pngData() else {
            throw InstagramError.missingStickerImageData
        }
        items[OptionsKey.stickerImage.rawValue] = stickerData
        items[OptionsKey.backgroundTopColor.rawValue] = backgroundTopColor
        items[OptionsKey.backgroundBottomColor.rawValue] = backgroundBottomColor
        guard UIApplication.shared.canOpenURL(urlScheme) else {
            throw InstagramError.couldNotOpenInstagram
        }
        let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
        UIPasteboard.general.setItems([items], options: pasteboardOptions)
        await UIApplication.shared.open(urlScheme)
    }
}

