import SwiftUI

struct HomeView<Stream: HomeViewStreamType>: View {
    @StateObject var viewStream: Stream
    @State var takenImage: UIImage? = nil

    public init(viewStream: Stream) {
        _viewStream = StateObject(wrappedValue: viewStream)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 5) {
                HStack {
                    Text("今日のお題")
                        .foregroundStyle(Color(hex: "0A3049"))
                        .font(.system(size: 16))
                        .bold()
                        .padding(.bottom)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.top)

                firstSectionView()
                    .background(Color(type: .offwhite))
                    .clipShape(RoundedRectangle(cornerRadius: 10), style: FillStyle())
                    .onTapGesture {
                        Task {
                            await viewStream.action(input: .didTapThemeView)
                        }
                    }
                    .padding(.horizontal, 16)

                HStack {
                    Text("カテゴリ")
                        .foregroundStyle(Color(hex: "0A3049"))
                        .font(.system(size: 16))
                        .bold()
                        .padding(.bottom)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.top)

                HStack(spacing: 20) {
                    NavigationLink(destination: {
                        CategoryHomeView(
                            takenImage: $viewStream.output.todayThemeModel.takenImage,
                            category: .eating("")
                        )
                    }, label: {
                        secondSectionView(image: UIImage(named: "eating")!, title: "ごはん")
                    })

                    NavigationLink(destination: {
                        CategoryHomeView(
                            takenImage: $viewStream.output.todayThemeModel.takenImage,
                            category: .sleeping("")
                        )
                    }, label: {
                        secondSectionView(image: UIImage(named: "sleeping")!, title: "おひるね")
                    })
                    
                    NavigationLink(destination: {
                        CategoryHomeView(
                            takenImage: $viewStream.output.todayThemeModel.takenImage,
                            category: .playing("")
                        )
                    }, label: {
                        secondSectionView(image: UIImage(named: "playing")!, title: "あそび")
                    })
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 16)

                HStack(spacing: 20) {
                    NavigationLink(destination: {
                        CategoryHomeView(
                            takenImage: $viewStream.output.todayThemeModel.takenImage,
                            category: .trouble("")
                        )
                    }, label: {
                        secondSectionView(image: UIImage(named: "trouble")!, title: "トラブル")
                    })
                    NavigationLink(destination: {
                        CategoryHomeView(
                            takenImage: $viewStream.output.todayThemeModel.takenImage,
                            category: .selfie("")
                        )
                    }, label: {
                        secondSectionView(image: UIImage(named: "selfie")!, title: "セルフィー")
                    })
                    Spacer()
                }
                .padding(.horizontal, 16)

                // deprecatedでくやしい
                if let takenImage = takenImage {
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
                                dateLabel: viewStream.output.todayThemeModel.dateLabel
                            )
                        ),
                        isActive: $viewStream.output.isNavigationActive
                    ) { EmptyView() }
                }
            }
            .padding(.horizontal, 16)
            .fullScreenCover(isPresented: $viewStream.output.shouldShowCameraView) {
                CameraView(outputImage: $takenImage)
                    .onDisappear {
                        Task {
                            await viewStream.action(input: .onCameraViewDisappear(takenImage: takenImage))
                        }
                    }
            }
            .background(Color(hex: "DCE0E3"))
            .onAppear {
                Task {
                    await viewStream.action(input: .onAppear)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "DCE0E3"))
        .scrollContentBackground(.hidden)
    }

    func secondSectionView(image: UIImage, title: String) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 64)
                .padding(.top, 8)
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "0A3049"))
                .padding(.bottom, 8)
        }
        .background(Color(type: .offwhite))
        .clipShape(RoundedRectangle(cornerRadius: 15), style: FillStyle())
    }

    func firstSectionView() -> some View {
        VStack(alignment: .center, spacing: 16) {
            HStack {
                Spacer()
                Text(viewStream.output.todayThemeModel.dateLabel)
                    .foregroundStyle(Color(hex: "0A3049"))
                    .padding(.top, 16)
                Spacer()
            }
            .padding(.horizontal, 16)

            Text(viewStream.output.todayThemeModel.category)
                .foregroundStyle(Color(hex: "0A3049"))
                .bold()
                .padding(.bottom, viewStream.output.todayThemeModel.takenImage == nil ? 16 : 0)

            if let takenImage = viewStream.output.todayThemeModel.takenImage {
                Image(uiImage: takenImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 16)
            }

            if let answer = viewStream.output.todayThemeModel.answer {
                HStack {
                    Text(answer)
                        .foregroundStyle(Color(type: .captionGray))
                        .font(.system(size: 14))
                        .frame(alignment: .leading)
                        .padding(.horizontal, 32)
                    Spacer()
                }
            }

            if viewStream.output.todayThemeModel.answer != nil {
                Button(action: {
                    Task {
                        await viewStream.action(input: .didTapThemeView)
                    }
                }, label: {
                    Text("再撮影する")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "0A3049"))
                        .underline()
                })
                .padding(.bottom)
            }
        }
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
