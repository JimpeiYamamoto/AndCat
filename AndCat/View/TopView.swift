import SwiftUI

struct TopListView<Stream: TopViewStreamType>: View {
    @StateObject var viewStream: Stream

    public init(viewStream: Stream) {
        _viewStream = StateObject(wrappedValue: viewStream)
    }

    var body: some View {
        VStack {
            if viewStream.output.isPresentLoadingView {
                ProgressView("読み込み中")
            } else {
                if viewStream.output.isPresentErrorView {
                    Text("エラーです")
                } else {
                    List {
                        ForEach([viewStream.output.pokemon ?? .init(id: 0, name: "nil")]) { pokemon in
                            Text("\(pokemon.name)")
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewStream.action(input: .onAppear)
            }
        }
    }
}

#Preview {
    TopListView(viewStream: TopViewStream.shared)
}
