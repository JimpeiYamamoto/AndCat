import Foundation
import SwiftUI

struct TakenResultView<Stream: TakenResultViewStreamType>: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewStream: Stream
    public let payLoad: FromHomeViewPayLoad

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
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
            }
            Text(viewStream.output.question ?? "")
                .foregroundStyle(Color.black)
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(type: .offwhite))
                    .padding(.horizontal, 20)
                TextField("", text: $viewStream.output.typedAnswer)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 30)
            }
            .frame(height: 50)
            Button(action: {
                Task {
                    await viewStream.action(input: .didTapCompleteButton)
                    presentationMode.wrappedValue.dismiss()
                }
            }, label: {
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color.white)
                        Text("完了")
                            .foregroundStyle(Color.black)
                    }
                    .frame(width: 100, height: 40)
                    .padding(.trailing, 30)
                }
            })
            .frame(height: 50)
            Spacer()
        }
        .onAppear(perform: {
            Task {
                await viewStream.action(input: .onAppear(self.payLoad))
            }
        })
        .padding(.top)
        .background(Color(type: .backGround))
    }
}

#Preview {
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
                    answer: "かわいい"
                )
            ),
            dateLabel: "10/5 土"
        )
    )
}
