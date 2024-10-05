import Foundation
import SwiftUI

struct TakenResultView<Stream: TakenResultViewStreamType>: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewStream: Stream
    public let payLoad: FromHomeViewPayLoad
    
    var todaysTopic: String {
        guard let category = viewStream.output.category else { return "" }
        switch category {
            case .eating(let title), .playing(let title),  .sleeping(let title), .trouble(let title), .selfie(let title), .history(let title):
                return title
        }
    }

    public init(viewStream: Stream, payload: FromHomeViewPayLoad) {
        self.payLoad = payload
        _viewStream = StateObject(wrappedValue: viewStream)
    }

    var body: some View {
        VStack(spacing: 20) {
            if let takenImage = viewStream.output.takenImage {
                Image(uiImage: takenImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(hex: "DCE0E3"))
                TextField(
                    "",
                    text: $viewStream.output.typedAnswer,
                    prompt: Text("Q. " + (viewStream.output.question ?? "")
                                )
                    .foregroundStyle(Color(hex: "787878"))
                    )
                .padding(.horizontal, 10)
            }
            .frame(height: 50)
            Button(action: {
                Task {
                    await viewStream.action(input: .didTapCompleteButton)
                    presentationMode.wrappedValue.dismiss()
                }
            }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(hex: "0A3049"))
                        Text("完了")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                    }
                    .frame(height: 44)
            }
            )
            .frame(height: 50)
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear(perform: {
            Task {
                await viewStream.action(input: .onAppear(self.payLoad))
            }
        })
        .padding(.top)
        .background(Color(hex: "E6EAED"))
        .navigationTitle(todaysTopic)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.white, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        TakenResultView(
            viewStream: TakenResultViewStream(
                pictureMemoryRepository: PictureMemoryRepository.shared
            ),
            payload: .init(
                pictureMemory: .init(
                    date: Date(),
                    image: UIImage(systemName: "star")!,
                    theme: .init(
                        category: .playing("猫が落ちてました"),
                        question: "様子は？",
                        answer: ""
                    )
                ),
                dateLabel: "10/5 土"
            )
        )
    }
}
