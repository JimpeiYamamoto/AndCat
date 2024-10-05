import Foundation
import UIKit

public protocol CalenderViewUseCaseType {
    func fetchPictureMemoryList(first: Date, last: Date) async -> CalenderViewUseCaseModel.FetchResult
}

public final class CalenderViewUseCase: CalenderViewUseCaseType {
    // 必要に応じてデータ永続化に利用するRepositoryなども保持する
    private let pictureMemoryRepository: PictureMemoryRepositoryType

    public init(pictureMemoryRepository: PictureMemoryRepositoryType) {
        self.pictureMemoryRepository = pictureMemoryRepository
    }

    public func fetchPictureMemoryList(first: Date, last: Date) async -> CalenderViewUseCaseModel.FetchResult {
        do {
            let pictureMemoryList = await pictureMemoryRepository.get(first: first, last: last)
            return .success(pictureMemoryList.map { .init(date: $0.date, image: $0.image, theme: $0.theme) })
        }
    }
}

public enum CalenderViewUseCaseModel {
    public enum FetchResult {
        case success([PictureMemory])

        public struct PictureMemory {
            let date: Date
            let image: UIImage
            let theme: Theme
        }
    }
}

extension CalenderViewUseCase {
    public static let shared = CalenderViewUseCase(pictureMemoryRepository: PictureMemoryRepository.shared)
}
