import SwiftUI

// Colorの拡張を追加
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// モデルの定義
public struct PictureMemoryModel: Identifiable {
    public let id = UUID()
    public let date: Date
    public let image: UIImage
    public let theme: ThemeModel
}

public enum CategoryModel {
    case eating(String)
    case sleeping(String)
    case playing(String)
    case trouble(String)
    case selfie(String)
    case history(String)

    // カテゴリー名の文字列を返す関数
    func toCategoryName() -> String {
        switch self {
        case .eating(_): return "eating"
        case .sleeping(_): return "sleeping"
        case .playing(_): return "playing"
        case .trouble(_): return "trouble"
        case .selfie(_): return "selfie"
        case .history(_): return "history"
        }
    }

    func toString() -> String {
        switch self {
        case .eating(let str): return str
        case .sleeping(let str): return str
        case .playing(let str): return str
        case .trouble(let str): return str
        case .selfie(let str): return str
        case .history(let str): return str
        }
    }
}

public struct ThemeModel {
    public let category: CategoryModel
    public let question: String
    public let answer: String
}

struct MemorialView: View {
    @State private var selectedCategory: String = "history"
    @State private var currentMemoryIndex: Int = 0
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer? = nil

    // モックデータの作成
    let memories: [String: [PictureMemoryModel]] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        // 画像を読み込む（アセットから）
        guard let image1 = UIImage(named: "アートボード 1"),
              let image2 = UIImage(named: "アートボード 2"),
              let image3 = UIImage(named: "アートボード 3") else {
            fatalError("画像の読み込みに失敗しました。")
        }

        // カテゴリーごとのモックデータを作成
        let eatingMemories = [
            PictureMemoryModel(date: formatter.date(from: "2022/01/01")!, image: image1, theme: ThemeModel(category: .eating("#今日のお昼ご飯"), question: "好きな食べ物は？", answer: "大好きなカツオのキャットフード")),
            PictureMemoryModel(date: formatter.date(from: "2022/02/01")!, image: image2, theme: ThemeModel(category: .eating("食事"), question: "苦手な食べ物は？", answer: "散歩の後の　CIAOちゅ～る　とりささみ！"))
        ]

        let sleepingMemories = [
            PictureMemoryModel(date: formatter.date(from: "2022/03/01")!, image: image1, theme: ThemeModel(category: .sleeping("#ご褒美をあげよう"), question: "よく見る夢は？", answer: "空を飛ぶ")),
            PictureMemoryModel(date: formatter.date(from: "2022/04/01")!, image: image2, theme: ThemeModel(category: .sleeping("睡眠"), question: "寝る前の習慣は？", answer: "読書"))
        ]

        let playingMemories = [
            PictureMemoryModel(date: formatter.date(from: "2022/05/01")!, image: image1, theme: ThemeModel(category: .playing("遊び"), question: "好きなゲームは？", answer: "チェス")),
            PictureMemoryModel(date: formatter.date(from: "2022/06/01")!, image: image2, theme: ThemeModel(category: .playing("遊び"), question: "趣味は？", answer: "ギター"))
        ]

        let troubleMemories = [
            PictureMemoryModel(date: formatter.date(from: "2022/07/01")!, image: image1, theme: ThemeModel(category: .trouble("トラブル"), question: "最近困ったことは？", answer: "パソコンが壊れた")),
            PictureMemoryModel(date: formatter.date(from: "2022/08/01")!, image: image3, theme: ThemeModel(category: .trouble("トラブル"), question: "苦労した経験は？", answer: "迷子になった"))
        ]

        let selfieMemories = [
            PictureMemoryModel(date: formatter.date(from: "2022/09/01")!, image: image2, theme: ThemeModel(category: .selfie("自撮り"), question: "お気に入りの写真は？", answer: "友達と撮った写真")),
            PictureMemoryModel(date: formatter.date(from: "2022/10/01")!, image: image3, theme: ThemeModel(category: .selfie("自撮り"), question: "最近の自撮りは？", answer: "新しい髪型"))
        ]

        let historyMemories = [
            PictureMemoryModel(date: formatter.date(from: "2022/11/01")!, image: image1, theme: ThemeModel(category: .history("歴史"), question: "印象に残っている出来事は？", answer: "卒業式")),
            PictureMemoryModel(date: formatter.date(from: "2022/12/01")!, image: image2, theme: ThemeModel(category: .history("歴史"), question: "過去の思い出は？", answer: "家族旅行"))
        ]

        return [
            "eating": eatingMemories,
            "sleeping": sleepingMemories,
            "playing": playingMemories,
            "trouble": troubleMemories,
            "selfie": selfieMemories,
            "history": historyMemories
        ]
    }()

    let categories = ["history", "eating", "sleeping", "playing", "trouble", "selfie"]
    let categoryKeyValues: [String: String] = [
        "history": "ヒストリー",
        "eating": "ごはん",
        "sleeping": "おひるね",
        "playing": "あそび",
        "trouble": "トラブル",
        "selfie": "セルフィー"
    ]

    var body: some View {
        VStack {
            // カテゴリー選択
            HStack(spacing: 5) {
                ForEach(categories, id: \.self) { category in
                    VStack {
                        Button(action: {
                            // 同じカテゴリーを選択した場合は無視
                            if selectedCategory != category {
                                selectedCategory = category
                                currentMemoryIndex = 0
                                startProgress()
                            }
                        }) {
                            ZStack {
                                // 背景色を持つ円を最背面に配置
                                Circle()
                                    .fill(selectedCategory == category ? Color(hex: "EFA98F").opacity(0.1) : Color.clear)
                                    .frame(width: 60, height: 60)
                                
                                // 画像ボタン
                                Image(category)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60) // サイズを調整
                                
                                // インジケーター
                                if selectedCategory == category {
                                    Circle()
                                        .trim(from: 0, to: progress)
                                        .stroke(Color(hex: "0A3049"), lineWidth: 2)
                                        .frame(width: 60, height: 60)
                                        .rotationEffect(Angle(degrees: -90))
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        // デフォルトのボタンスタイルを無効化
                        Text(categoryKeyValues[category]!)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "0A3049"))
                    }
                }
            }
            .padding()
            .background(Color.white) // 必要に応じてHStack全体の背景を白に設定

            Spacer()

            // 選択されたカテゴリーの現在の画像と情報を表示
            if let memories = memories[selectedCategory], !memories.isEmpty {
                let memory = memories[currentMemoryIndex]
                VStack(alignment: .leading, spacing: 8) {
                    Image(uiImage: memory.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .cornerRadius(12)
                        .clipped()

                    // 情報を表示（カテゴリの文字列と日付を横に詰めて表示）
                    HStack(spacing: 0) {
                        Text("\(memory.theme.category.toString())")
                            .font(.headline)
                        Text(" ") // 必要に応じてスペースを追加
                        Text("\(formattedDate(memory.date))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // answer の部分を角丸の背景で囲む
                    Text("\(memory.theme.answer)")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray5))
                        )
                }
                .padding() // 画像とテキスト全体にパディングを適用
            } else {
                Text("No data available")
                    .font(.title)
                    .padding()
            }

            Spacer()
        }
        .background(Color(.systemGray6))
        .onAppear {
            // ビューが表示されたときにプログレスを開始
            startProgress()
        }
        .onDisappear {
            // ビューが非表示になったときにタイマーを無効化
            timer?.invalidate()
        }
    }

    // 日付をフォーマットする関数
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    // プログレスインジケーターと画像の切り替えを開始
    func startProgress() {
        progress = 0.0
        timer?.invalidate() // 既存のタイマーを無効化

        guard let memories = memories[selectedCategory], !memories.isEmpty else {
            return
        }

        let numberOfMemories = memories.count
        let imageDuration = 3.0 // 各画像の表示時間を3秒に設定
        let totalDuration = imageDuration * Double(numberOfMemories)

        // プログレスアニメーションを開始
        withAnimation(.linear(duration: totalDuration)) {
            progress = 1.0
        }

        // タイマーを設定して画像インデックスを更新
        timer = Timer.scheduledTimer(withTimeInterval: imageDuration, repeats: true) { _ in
            currentMemoryIndex += 1
            if currentMemoryIndex >= numberOfMemories {
                currentMemoryIndex = 0
                progress = 0.0
                timer?.invalidate()
            }
        }
    }
}

struct MemorialView_Previews: PreviewProvider {
    static var previews: some View {
        MemorialView()
    }
}
