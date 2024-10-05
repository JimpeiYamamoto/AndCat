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

                firstSectionView()
                    .padding(.horizontal, 16)
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

                HStack(spacing: 20) {
                    secondSectionView(image: UIImage(named: "eating")!, title: "ごはん")
                    secondSectionView(image: UIImage(named: "sleeping")!, title: "おひるね")
                    secondSectionView(image: UIImage(named: "playing")!, title: "あそび")
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 16)

                HStack(spacing: 20) {
                    secondSectionView(image: UIImage(named: "trouble")!, title: "トラブル")
                    secondSectionView(image: UIImage(named: "selfie")!, title: "セルフィー")
                    Spacer()
                }
                .padding(.horizontal, 16)

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
        .padding(.horizontal, 16)
        .background(Color(type: .backGround))
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
                .foregroundStyle(Color.black)
                .padding(.bottom, 8)
        }
        .background(Color(type: .offwhite))
        .clipShape(RoundedRectangle(cornerRadius: 15), style: FillStyle())
    }

    func firstSectionView() -> some View {
        VStack(alignment: .center, spacing: 16) {
            HStack {
                Spacer()
                Text(viewStream.output.dateLabel)
                    .foregroundStyle(Color.black)
                    .padding(.top, 16)
                Spacer()
            }
            .padding(.horizontal, 16)

            Text(viewStream.output.category)
                .foregroundStyle(Color.black)
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
            
                HStack {
                    Text("今日のお題")
                        .foregroundStyle(Color.black)
                        .font(.title2)
                        .bold()
                        .padding(.bottom)
                    Spacer()
                }
                .padding(.top)
                VStack(alignment: .center, spacing: 5) {
                    Text("10/5 (土)")
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    Text("# 猫が落ちてました")
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .bold()
                    AsyncImage(
                        url: URL(string: "https://t3.ftcdn.net/jpg/02/36/99/22/360_F_236992283_sNOxCVQeFLd5pdqaKGh8DRGMZy7P4XKm.jpg")!
                    ) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                    } placeholder: {
                        ProgressView("読み見込み中")
                    }
                    Text("コメントコメントコメントコメントコメントコメントコメントコメント")
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                }
                .background(Color(type: .offwhite))
                .clipShape(RoundedRectangle(cornerRadius: 10), style: FillStyle())
                .onTapGesture {
                    shouldShowCameraView.toggle()
                }
                .background(RectangleGetter(rect: $rect))

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

// https://qiita.com/tsuzuki817/items/a3d2470ba9df07ed0d99
struct RectangleGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            self.createView(proxy: geometry)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        return Rectangle().fill(Color.clear)
    }
}

extension UIView {
    func getImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
 
extension UIImage {
    func roundedCorners(radius: CGFloat) -> UIImage {
        
        return UIGraphicsImageRenderer(size: self.size).image { context in
            
            let rect = context.format.bounds
            // Rectを角丸にする
            let roundedPath = UIBezierPath(roundedRect: rect,
                                           cornerRadius: radius)
            roundedPath.addClip()
            // UIImageを描画
            draw(in: rect)
        }
    }
}
