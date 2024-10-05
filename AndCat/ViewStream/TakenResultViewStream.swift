import Foundation
import UIKit

public protocol TakenResultViewStreamType: ViewStreamType
where Output == TakenResultViewStreamModel.Output,
      Input == TakenResultViewStreamModel.Input,
      State == TakenResultViewStreamModel.State
{}

public final class TakenResultViewStream: TakenResultViewStreamType {
    public var state = TakenResultViewStreamModel.State()

    private let pictureMemoryRepository: PictureMemoryRepositoryType

    public init(pictureMemoryRepository: PictureMemoryRepositoryType) {
        self.pictureMemoryRepository = pictureMemoryRepository
    }

    @Published public var output = TakenResultViewStreamModel.Output(
        typedAnswer: "",
        dateLabel: ""
    )

    @MainActor
    public func action(input: TakenResultViewStreamModel.Input) async {
        switch input {
        case .didTapCompleteButton:
            guard let takenImage = output.takenImage else {
                return
            }
            Task.detached(priority: .background) { [weak self] in
                await self?.pictureMemoryRepository.save(
                    .init(
                        date: Date(),
                        image: takenImage,
                        theme: .init(
                            category: .playing("猫が落ちてました"),
                            question: "どんな様子ですか？",
                            answer: self?.output.typedAnswer ?? ""
                        )
                    )
                )
            }
        case let .onAppear(payload):
            output = .init(
                typedAnswer: payload.pictureMemory.theme.answer,
                dateLabel: payload.dateLabel,
                takenImage: payload.pictureMemory.image,
                question: payload.pictureMemory.theme.question
            )
        }
    }
}

public enum TakenResultViewStreamModel {
    public enum Input {
        case onAppear(FromHomeViewPayLoad)
        case didTapCompleteButton
    }

    public struct Output {
        public var typedAnswer: String
        public var dateLabel: String
        public var takenImage: UIImage?
        public var question: String?
    }

    public struct State {
        public init() {}
    }
}

extension TakenResultViewStream {
    public static let shared = TakenResultViewStream(pictureMemoryRepository: PictureMemoryRepository.shared)
}
