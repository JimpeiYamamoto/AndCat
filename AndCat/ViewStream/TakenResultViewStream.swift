import Foundation
import UIKit

public protocol TakenResultViewStreamType: ViewStreamType
where Output == TakenResultViewStreamModel.Output,
      Input == TakenResultViewStreamModel.Input,
      State == TakenResultViewStreamModel.State
{}

public final class TakenResultViewStream: TakenResultViewStreamType {
    public var state = TakenResultViewStreamModel.State(pictureMemory: nil)

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
            guard let pictureMemory = state.pictureMemory else {
                return
            }
            Task.detached(priority: .background) { [weak self] in
                await self?.pictureMemoryRepository.save(
                    .init(
                        date: pictureMemory.date,
                        image: pictureMemory.image,
                        theme: .init(
                            category: pictureMemory.theme.category,
                            question: pictureMemory.theme.question,
                            answer: self?.output.typedAnswer ?? ""
                        )
                    )
                )
            }
        case let .onAppear(payload):
            state.pictureMemory = payload.pictureMemory
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
        public var pictureMemory: PictureMemory?
        public init(pictureMemory: PictureMemory?) {
            self.pictureMemory = pictureMemory
        }
    }
}

extension TakenResultViewStream {
    public static let shared = TakenResultViewStream(pictureMemoryRepository: PictureMemoryRepository.shared)
}
