import SwiftUI

struct HomeView<Stream: HomeViewStreamType>: View {
    @StateObject var viewStream: Stream

    public init(viewStream: Stream) {
        _viewStream = StateObject(wrappedValue: viewStream)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
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
                Text(viewStream.output.dateLabel)
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                Text(viewStream.output.question ?? "")
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .bold()
                if let takenImage = viewStream.output.takenImage {
                    Image(uiImage: takenImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding()
                }
                Text(viewStream.output.answer ?? "")
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)

            }
            .background(Color(type: .offwhite))
            .clipShape(RoundedRectangle(cornerRadius: 10), style: FillStyle())
            .onTapGesture {
                Task {
                    await viewStream.action(input: .didTapThemeView)
                }
            }

            Spacer()
            // deprecatedでくやしい
            NavigationLink(
                destination: TakenResultView(takenImage: viewStream.output.takenImage),
                isActive: $viewStream.output.isNavigationActive
            ) { EmptyView() }
        }
        .padding(.horizontal)
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
}

extension HomeView {
    enum Destination {
        case takenResultView
    }
}

#Preview {
    HomeView(viewStream: HomeViewStream.shared)
}
