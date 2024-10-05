import Foundation
import SwiftUI

struct TakenResultView: View {
    let takenImage: UIImage?
    @State var answerText: String = ""
    @Environment(\.presentationMode) var presentationMode

    public init(takenImage: UIImage?) {
        self.takenImage = takenImage
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: takenImage!)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(type: .offwhite))
                    .padding(.horizontal, 20)
                TextField("  Q どんな状態でしたか", text: $answerText)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 30)
            }
            .frame(height: 50)
            Button(action: {
                presentationMode.wrappedValue.dismiss()
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
        .padding(.top)
        .background(Color(type: .backGround))
    }
}

#Preview {
    TakenResultView(takenImage: UIImage(systemName: "star"))
}
