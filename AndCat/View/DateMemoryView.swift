//
//  DateMemoryView.swift
//  AndCat
//
//  Created by 上別縄祐也 on 2024/10/06.
//

import SwiftUI

struct DateMemoryView: View {
    
    private let pictureMemory: CalenderViewStreamModel.PictureMemory
    private let navigationTitle: String
    private let navigationSubTitle: String
    
    init(pictureMemory: CalenderViewStreamModel.PictureMemory) {
        self.pictureMemory = pictureMemory
        
        // 日付をフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        self.navigationTitle = formatter.string(from: pictureMemory.date)
        
        formatter.dateFormat = "H:mm"
        self.navigationSubTitle = formatter.string(from: pictureMemory.date)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(pictureMemory.theme.category.getString())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "0A3049"))
                Spacer()
            }
            Image(uiImage: pictureMemory.image)
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(hex: "DCE0E3"))
                HStack {
                    Text(pictureMemory.theme.answer)
                        .frame(alignment: .leading)
                        .foregroundStyle(Color(hex: "787878"))
                        .padding(.horizontal, 10)
                    Spacer()
                }
            }
            .frame(height: 50)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top)
        .background(Color(hex: "E6EAED"))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.white, for: .navigationBar)
    }
}

#Preview {
    let pictureMemory = CalenderViewStreamModel.PictureMemory(date: Date(), image: UIImage(systemName: "cat")!, theme: .init(category: .eating("eating"), question: "Q: Eating", answer: "A: Eating"))
    return DateMemoryView(pictureMemory: pictureMemory)
}
