//
//  DateMemoryView.swift
//  AndCat
//
//  Created by 上別縄祐也 on 2024/10/06.
//

import SwiftUI

struct DateMemoryView: View {
    
    private let pictureMemory: CalendarViewStreamModel.PictureMemory
    private let navigationTitle: String
    private let navigationSubTitle: String
    
    @State private var rect: CGRect = .zero
    
    init(pictureMemory: CalendarViewStreamModel.PictureMemory) {
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
        .background(RectangleGetter(rect: $rect))
        .padding(.horizontal, 16)
        .padding(.top)
        .background(Color(hex: "E6EAED"))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.white, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image("Share")
                    .onTapGesture {
                        Task {
                            do {
                                guard let uiImage = UIApplication.shared.windows[0].rootViewController?.view!.getImage(rect: self.rect).roundedCorners(radius: 8) else { return }
                                try await InstagramRepository.shared.share(stickerImage: uiImage, backgroundTopColor: "#E6EAED", backgroundBottomColor: "#E6EAED")
                            }
                        }
                    }
            }
        }
    }
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

#Preview {
    let pictureMemory = CalendarViewStreamModel.PictureMemory(date: Date(), image: UIImage(systemName: "cat")!, theme: .init(category: .eating("eating"), question: "Q: Eating", answer: "A: Eating"))
    return DateMemoryView(pictureMemory: pictureMemory)
}
