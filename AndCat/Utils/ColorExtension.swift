import Foundation
import SwiftUI

extension Color {
    init(type: ColorType) {
        switch type {
        case .backGround:
            self.init(red: 144 / 255.0, green: 144.0 / 255.0, blue: 144.0 / 241.0)
        case .offwhite:
            self.init(red: 241.0 / 255.0, green: 241.0 / 255.0, blue: 241.0 / 255.0)
        }
    }

    enum ColorType {
        case backGround
        case offwhite
    }
}
