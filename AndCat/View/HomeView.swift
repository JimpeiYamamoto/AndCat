import SwiftUI

struct HomeView<Stream: HomeViewStreamType>: View {
    @StateObject var viewStream: Stream

    public init(viewStream: Stream) {
        _viewStream = StateObject(wrappedValue: viewStream)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 5) {
                HStack {
                    Text("今日のお題")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 16))
                        .bold()
                        .padding(.bottom)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.top)
                VStack(alignment: .center, spacing: 16) {
                    Text(viewStream.output.dateLabel)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    Text(viewStream.output.category)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .bold()
                        .padding(.bottom, viewStream.output.takenImage == nil ? 16 : 0)
                    if let takenImage = viewStream.output.takenImage {
                        Image(uiImage: takenImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal, 16)
                    }
                    if let answer = viewStream.output.answer {
                        HStack {
                            Text(answer)
                                .foregroundStyle(Color(type: .captionGray))
                                .font(.system(size: 14))
                                .frame(alignment: .leading)
                                .padding(.horizontal, 32)
                            Spacer()
                        }
                    }
                    if viewStream.output.answer != nil {
                        Button(action: {
                            Task {
                                await viewStream.action(input: .didTapThemeView)
                            }
                        }, label: {
                            Text("再撮影する")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.black)
                                .underline()
                        })
                        .padding(.bottom)

                    }
                }
                .background(Color(type: .offwhite))
                .clipShape(RoundedRectangle(cornerRadius: 10), style: FillStyle())
                .onTapGesture {
                    Task {
                        await viewStream.action(input: .didTapThemeView)
                    }
                }

                HStack {
                    Text("カテゴリ")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 16))
                        .bold()
                        .padding(.bottom)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.top)

                VStack {
                    HStack(spacing: 20) {
                        Rectangle()
                            .fill(Color.red)
                        Rectangle()
                            .fill(Color.green)
                        Rectangle()
                            .fill(Color.blue)
                    }
                    .padding(.bottom, 16)

                    HStack(spacing: 20) {
                        Rectangle()
                            .fill(Color.red)
                        Rectangle()
                            .fill(Color.green)
                        Spacer()
                    }
                }
                .background(Color(type: .offwhite))
                .clipShape(RoundedRectangle(cornerRadius: 10), style: FillStyle())

                // deprecatedでくやしい
                if let takenImage = viewStream.output.takenImage {
                    NavigationLink(
                        destination: TakenResultView(
                            viewStream: TakenResultViewStream.shared,
                            payload: .init(
                                pictureMemory: .init(
                                    date: viewStream.state.pictureMemory.date,
                                    image: takenImage,
                                    theme: .init(
                                        category: viewStream.state.pictureMemory.theme.category,
                                        question: viewStream.state.pictureMemory.theme.question,
                                        answer: ""
                                    )
                                ),
                                dateLabel: viewStream.output.dateLabel
                            )
                        ),
                        isActive: $viewStream.output.isNavigationActive
                    ) { EmptyView() }
                }
            }
            .padding(.horizontal, 16)
            .fullScreenCover(isPresented: $viewStream.output.shouldShowCameraView) {
                CameraView(image: $viewStream.output.takenImage)
                    .onDisappear {
                        if viewStream.output.takenImage != nil {
                            Task {
                                await viewStream.action(input: .onCameraViewDisappear)
                            }
                        }
                    }
            }
            .background(Color(type: .backGround))
            .onAppear {
                Task {
                    await viewStream.action(input: .onAppear)
                }
            }

        }
        .background(Color(type: .backGround))
        .scrollContentBackground(.hidden)
    }
}

extension HomeView {
    enum Destination {
        case takenResultView
    }
}

public struct FromHomeViewPayLoad {
    public let pictureMemory: PictureMemory
    public let dateLabel: String
}

#Preview {
    HomeView(viewStream: HomeViewStream.shared)
}
