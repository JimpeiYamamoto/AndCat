import Foundation
import UIKit

public protocol HomeViewUseCaseType {
    func fetchTodayPictureMemory() async -> HomeViewUseCaseModel.FetchResult
}

public final class HomeViewUseCase: HomeViewUseCaseType {
    private let pictureMemoryRepository: PictureMemoryRepositoryType

    private init(pictureMemoryRepository: PictureMemoryRepositoryType) {
        self.pictureMemoryRepository = pictureMemoryRepository
    }

    public func fetchTodayPictureMemory() async -> HomeViewUseCaseModel.FetchResult {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "M/d (E)"
        let todayString = dateFormatter.string(from: today)

        let _pictureMemory = await Task.detached(priority: .background) {
            await self.pictureMemoryRepository.get(
                first: today,
                last: tomorrow
            )
        }.value.last

        guard let pictureMemory = _pictureMemory else {
            return .display(
                .init(
                    category: Theme.initialTheme.category ,
                    date: todayString,
                    takenImage: nil,
                    question: Theme.initialTheme.question,
                    answer: nil
                )
            )
        }
        return .display(
            .init(
                category: pictureMemory.theme.category,
                date: todayString,
                takenImage: pictureMemory.image,
                question: pictureMemory.theme.question,
                answer: pictureMemory.theme.answer
            )
        )
    }
}

public enum HomeViewUseCaseModel {
    public enum FetchResult {
        case display(PictureMemory)

        public struct PictureMemory {
            public let category: Category
            public let date: String
            public let takenImage: UIImage?
            public let question: String?
            public let answer: String?

            public init(
                category: Category,
                date: String,
                takenImage: UIImage?,
                question: String?,
                answer: String?
            ) {
                self.category = category
                self.date = date
                self.takenImage = takenImage
                self.question = question
                self.answer = answer
            }
        }
    }
}

extension HomeViewUseCase {
    @MainActor
    public static let shared = HomeViewUseCase(pictureMemoryRepository: PictureMemoryRepository.shared)
}
