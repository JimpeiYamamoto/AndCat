import SwiftUI

struct HomeView: View {
    @State var takenImage: UIImage? = nil
    @State var shouldShowCameraView: Bool = false
    @State var isNavigationActive: Bool = false

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

            Spacer()
            // deprecatedでくやしい
            NavigationLink(
                destination: TakenResultView(takenImage: takenImage),
                isActive: $isNavigationActive
            ) { EmptyView() }
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $shouldShowCameraView) {
            CameraView(image: $takenImage)
                .onDisappear {
                    if takenImage != nil {
                        isNavigationActive.toggle()
                    }
                }
        }
        .background(Color(type: .backGround))
    }
}

extension HomeView {
    enum Destination {
        case takenResultView
    }
}

#Preview {
    HomeView()
}
