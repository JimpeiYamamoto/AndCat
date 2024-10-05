import Foundation
import UIKit

public protocol HomeViewStreamType: ViewStreamType
where Output == HomeViewStreamModel.Output,
      Input == HomeViewStreamModel.Input,
      State == HomeViewStreamModel.State
{}

public final class HomeViewStream: HomeViewStreamType {
    public var state = HomeViewStreamModel.State(
        pictureMemory: .init(
            date: Date(),
            image: UIImage(),
            theme: HomeViewStream.initialTheme
        )
    )

    private let pictureMemoryRepository: PictureMemoryRepositoryType

    public init(pictureMemoryRepository: PictureMemoryRepositoryType) {
        self.pictureMemoryRepository = pictureMemoryRepository
    }

    @Published public var output = HomeViewStreamModel.Output(
        dateLabel: "",
        takenImage: nil,
        question: nil,
        answer: nil,
        isNavigationActive: false,
        shouldShowCameraView: false
    )

    @MainActor
    public func action(input: HomeViewStreamModel.Input) async {
        switch input {
        case .didTapThemeView:
            output.shouldShowCameraView.toggle()

        case .onAppear:

            let now = Date()
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: now)
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.dateFormat = "M/d (E)"
            let todayString = dateFormatter.string(from: today)

            output.dateLabel = todayString
            let pictureMemory = await Task.detached(priority: .background) {
                await self.pictureMemoryRepository.get(
                    first: today,
                    last: tomorrow
                )
            }.value.last

            guard let pictureMemory = pictureMemory else {
                output.question = HomeViewStream.initialTheme.question
                return
            }

            state.pictureMemory = pictureMemory
            output.question = pictureMemory.theme.question
            output.answer = pictureMemory.theme.answer
            output.takenImage = pictureMemory.image

        case .onCameraViewDisappear:
            output.isNavigationActive.toggle()
        }
    }
}

public enum HomeViewStreamModel {
    public enum Input {
        case onAppear
        case didTapThemeView
        case onCameraViewDisappear
    }

    public struct Output {
        public var dateLabel: String
        public var takenImage: UIImage?
        public var question: String?
        public var answer: String?
        public var isNavigationActive: Bool
        public var shouldShowCameraView: Bool
    }

    public struct State {
        public var pictureMemory: PictureMemory
        public init(pictureMemory: PictureMemory) {
            self.pictureMemory = pictureMemory
        }
    }
}

extension HomeViewStream {
    public static let shared = HomeViewStream(pictureMemoryRepository: PictureMemoryRepository.shared)

    public static let initialTheme = Theme(
        category: .playing("猫が落ちてきました"),
        question: "あなたは今どんな気分",
        answer: ""
    )
}
