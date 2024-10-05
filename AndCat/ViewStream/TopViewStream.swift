import Foundation

public protocol TopViewStreamType: ViewStreamType
where Output == TopViewStreamModel.Output,
      Input == TopViewStreamModel.Input,
      State == TopViewStreamModel.State
{}

public final class TopViewStream: TopViewStreamType {

    @Published public var output = TopViewStreamModel.Output()

    public var state = TopViewStreamModel.State()

    @MainActor
    public func action(
        input: TopViewStreamModel.Input
    ) async {}
}

public enum TopViewStreamModel {
    public enum Input {}

    public struct Output {}

   public struct State {}
}

extension TopViewStream {
    public static let shared = TopViewStream()
}
