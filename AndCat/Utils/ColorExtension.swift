import Foundation
import SwiftUI

extension Color {
    init(type: ColorType) {
        switch type {
        case .backGround:
            self.init(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0)
        case .offwhite:
            self.init(red: 241.0 / 255.0, green: 241.0 / 255.0, blue: 241.0 / 255.0)
        case .captionGray:
            self.init(red: 120.0 / 255.0, green: 120.0 / 255.0, blue: 120.0 / 255.0)
        }
    }

    enum ColorType {
        case backGround
        case offwhite
        case captionGray
    }
}
