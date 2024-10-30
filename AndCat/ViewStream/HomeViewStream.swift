import Foundation
import UIKit

public protocol HomeViewStreamType: ViewStreamType
where Output == HomeViewStreamModel.Output,
      Input == HomeViewStreamModel.Input,
      State == HomeViewStreamModel.State
{}

public final class HomeViewStream: HomeViewStreamType {
    private let useCase: HomeViewUseCaseType

    private init(useCase: HomeViewUseCaseType) {
        self.useCase = useCase
    }

    @Published public var output = HomeViewStreamModel.Output(
        todayThemeModel: .init(
            category: "",
            dateLabel: "",
            takenImage: nil,
            question: nil,
            answer: nil
        ),
        isNavigationActive: false,
        shouldShowCameraView: false
    )

    public var state = HomeViewStreamModel.State(
        pictureMemory: .init(
            date: Date(),
            image: UIImage(),
            theme: Theme.initialTheme
        )
    )

    @MainActor
    public func action(input: HomeViewStreamModel.Input) async {
        switch input {
        case .didTapThemeView:
            output.shouldShowCameraView.toggle()

        case .onAppear:

            let displayResult = await Task.detached(priority: .background) { [useCase] in
                await useCase.fetchTodayPictureMemory()
            }.value

            switch displayResult {
            case .display(let pictureMemory):
                let category = switch pictureMemory.category {
                case let .eating(text),
                    let .sleeping(text),
                    let .playing(text),
                    let .selfie(text),
                    let .trouble(text):
                    text
                }
                output.todayThemeModel = .init(
                    category: category,
                    dateLabel: pictureMemory.date,
                    takenImage: pictureMemory.takenImage,
                    question: pictureMemory.question,
                    answer: pictureMemory.answer
                )
                guard let takenImage = pictureMemory.takenImage,
                      let question = pictureMemory.question,
                      let answer = pictureMemory.answer else {
                    return
                }
                state.pictureMemory = .init(
                    date: Date(),
                    image: takenImage,
                    theme: .init(
                        category: pictureMemory.category,
                        question: question,
                        answer: answer
                    )
                )
            }

        case .onCameraViewDisappear(let takenImage):
            guard let _ = takenImage else { return }
            output.isNavigationActive.toggle()
        }
    }
}

public enum HomeViewStreamModel {
    public enum Input {
        case onAppear
        case didTapThemeView
        case onCameraViewDisappear(takenImage: UIImage?)
    }

    public struct Output {
        public var todayThemeModel: TodayThemeModel
        public var isNavigationActive: Bool
        public var shouldShowCameraView: Bool

        public struct TodayThemeModel {
            public var category: String
            public var dateLabel: String
            public var takenImage: UIImage?
            public var question: String?
            public var answer: String?

            public init(
                category: String,
                dateLabel: String,
                takenImage: UIImage?,
                question: String?,
                answer: String?
            ) {
                self.category = category
                self.dateLabel = dateLabel
                self.takenImage = takenImage
                self.question = question
                self.answer = answer
            }
        }
    }

    public struct State {
        public var pictureMemory: PictureMemory
        public init(pictureMemory: PictureMemory) {
            self.pictureMemory = pictureMemory
        }
    }
}

extension HomeViewStream {
    @MainActor
    public static let shared = HomeViewStream(useCase: HomeViewUseCase.shared)
}
