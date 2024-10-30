//
//  CategoryHomeView.swift
//  AndCat
//
//  Created by KoichiroUeki on 2024/10/06.
//

import Foundation
import SwiftUI

struct CategoryButtonCell: View {
    var category: Category
    
    var text: String {
        switch category {
            case .eating(let string):
                return string
            case .sleeping(let string):
                return string
            case .playing(let string):
                return string
            case .trouble(let string):
                return string
            case .selfie(let string):
                return string
        }
    }

    var body: some View {
            Text(text)
                .foregroundStyle(Color(hex: "0A3049"))
                .font(.system(size: 17))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .padding(.horizontal, 16)
                )
            .frame(height: 44)
        .padding(.vertical, 10)
    }
}

struct CategoryHomeView: View {
    @State var isCameraPresented: Bool = false
    @State var isResultPresent: Bool = false
    @Binding var takenImage: UIImage?
    let category: Category
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("今日のお題")
                    .foregroundStyle(Color(hex: "0A3049"))
                    .font(.system(size: 16))
                    .bold()
                    .padding(.bottom)
                    .padding(.leading, 8)
                Spacer()
            }
            
            VStack {
                let categories = prepareCategorys(for: category)
                ForEach(categories.indices) { index in
                    CategoryButtonCell(category: categories[index])
//                        } onTap: {category in })
                        .onTapGesture {
                            self.isCameraPresented = true
                        }
                }
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $isResultPresent) {
            if takenImage == nil {
                Text("")
            } else {
                TakenResultView(
                    viewStream: TakenResultViewStream.shared,
                    payload: .init(
                        pictureMemory: .init(
                            date: .now,
                            image: takenImage!,
                            theme: .init(
                                category: category,
                                question: "",
                                answer: ""
                            )
                        ),
                        dateLabel: "dateLabel"
                    )
                )
            }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView(outputImage: $takenImage)
                .onDisappear {
                    if takenImage != nil {
                        self.takenImage = takenImage
                        self.isResultPresent = true
                    }
                }
        }
        .padding(.top, 20)
        .background(Color(hex: "DCE0E3"))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundStyle(Color(hex: "0A3049"))
                    .bold()
            }
        }
    }
}

extension CategoryHomeView {
    var title: String {
        switch category {
            case .eating:
                "ごはん"
            case .sleeping:
                "おひるね"
            case .playing:
                "あそび"
            case .trouble:
                "トラブル"
            case .selfie:
                "セルフィー"
        }
    }
    
    func prepareCategorys(for category: Category) -> [Category] {
        switch category {
        case .eating:
            eatingCategory
        case .sleeping:
            sleepginCategory
        case .playing:
            playingCategory
        case .trouble:
            troubleCategory
        case .selfie:
            selfieCategory
        }
    }
    
    var eatingCategory: [Category] {
        [
        .eating("#今日のお昼ご飯"),
        .eating("#ご褒美をあげよう")
        ]
    }

    var sleepginCategory: [Category] {
        [
        .sleeping("#ラブラブ添い寝"),
        .sleeping("#居眠り激写")
        ]
    }
    
    var playingCategory: [Category] {
        [
            .playing("#なんか走ってる"),
            .playing("#溶けてた")
        ]
    }

    var troubleCategory: [Category] {
        [
            .trouble("#ご機嫌ななめ"),
            .trouble("#スーパーうんちタイム")
        ]
    }
    
    var selfieCategory: [Category] {
        [
            .selfie("#みんなでパシャリ")
        ]
    }
}
