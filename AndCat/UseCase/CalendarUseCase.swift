import Foundation
import UIKit

public protocol CalendarViewUseCaseType {
    func fetchPictureMemoryList(first: Date, last: Date) async -> CalendarViewUseCaseModel.FetchResult
}

public final class CalendarViewUseCase: CalendarViewUseCaseType {
    // 必要に応じてデータ永続化に利用するRepositoryなども保持する
    private let pictureMemoryRepository: PictureMemoryRepositoryType

    public init(pictureMemoryRepository: PictureMemoryRepositoryType) {
        self.pictureMemoryRepository = pictureMemoryRepository
    }

    public func fetchPictureMemoryList(first: Date, last: Date) async -> CalendarViewUseCaseModel.FetchResult {
        do {
            let pictureMemoryList = await pictureMemoryRepository.get(first: first, last: last)
            return .success(pictureMemoryList.map { .init(date: $0.date, image: $0.image, theme: $0.theme) })
        }
    }
}

public enum CalendarViewUseCaseModel {
    public enum FetchResult {
        case success([PictureMemory])

        public struct PictureMemory {
            let date: Date
            let image: UIImage
            let theme: Theme
        }
    }
}

extension CalendarViewUseCase {
    @MainActor
    public static let shared = CalendarViewUseCase(pictureMemoryRepository: PictureMemoryRepository.shared)
}
