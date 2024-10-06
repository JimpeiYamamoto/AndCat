import Foundation
import SwiftData
import UIKit

public protocol PictureMemoryRepositoryType {
    func get(first: Date, last: Date) async -> [PictureMemory]
    func get(with category: Category) async -> [PictureMemory]
    func save(_ pictureMemory: PictureMemory) async
}

// CategoryのFilterがうまく動かないので、CategoryをIntに変換する。Intならなんか動く。
func categoryToInt(_ category: Category) -> Int {
    switch category {
        case .eating:
            return 0
        case .sleeping:
            return 1
        case .playing:
            return 2
        case .trouble:
            return 3
        case .selfie:
            return 4
    }
}

// SwiftDataに保存するにはClassにする必要がある。
@Model
class PictureMemoryDataModel: Codable {
    public let date: Date
    public let image: Data
    public let theme: Theme
    
    // Category FilterのためのFieldです。
    public let categoryModel: Int
    
    init(date: Date, image: Data, theme: Theme) {
        self.date = date
        self.image = image
        self.theme = theme
        self.categoryModel = categoryToInt(theme.category)
    }
    
    init(_ pictureMemory: PictureMemory) {
        self.date = pictureMemory.date
        self.theme = pictureMemory.theme
        self.image = pictureMemory.image.pngData()!
        self.categoryModel = categoryToInt(pictureMemory.theme.category)
    }
    
    // MARK: Codable Conformance
    enum CodingKeys: String, CodingKey {
        case date
        case theme
        case image
        case categoryModel
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(theme, forKey: .theme)
        try container.encode(image, forKey: .image)
        try container.encode(categoryModel, forKey: .categoryModel)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decode(Date.self, forKey: .date)
        theme = try values.decode(Theme.self, forKey: .theme)
        image = try values.decode(Data.self, forKey: .image)
        categoryModel = try values.decode(Int.self, forKey: .categoryModel)
    }
}

// FYI: Modelの型の中身とかを変えると、crashするかも。(DBに保存されてるデータの型と、変更後の型が違ってcrash). その時は、新しいSimulatorを使うなどする。
// modelContainer.mainContextがMainActorなので、MainActorにした。(mainContextにアクセスするときに、awaitを書くのがめんどくさいので)
@MainActor
class PictureMemoryRepository: PictureMemoryRepositoryType {
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        return modelContainer.mainContext
    }
    
    init() {
        // スキーマとモデル構成を作成
        let schema = Schema([PictureMemoryDataModel.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        // モデルコンテナを初期化
        self.modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        
        
        // Insert Dummy あとで消す
        Task {
            //await insertDummyDataForDemo()
        }
    }
    
    // firstDateとlastDateの間に作成されたデータを返却する
    // エラーやデータが空の場合は、EmptyListを返却する
    func get(first: Date, last: Date) async -> [PictureMemory] {
        let predicate = #Predicate<PictureMemoryDataModel> { data in
            return data.date >= first && data.date <= last
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let data = try? context.fetch(descriptor)
        guard let data else { return [] }
        return data.compactMap { PictureMemory(date: $0.date, image: UIImage(data: $0.image)!, theme: $0.theme )}
    }
    
    // Categoryが一致するデータを返却する
    // エラーやデータが空の場合は、EmptyListを返却する
    func get(with category: Category) async -> [PictureMemory] {
        let categoryModel = categoryToInt(category)
        let predicate = #Predicate<PictureMemoryDataModel> { data in
            data.categoryModel == categoryModel
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        let data = try? context.fetch(descriptor)
        guard let data else { return [] }
        return data.compactMap { PictureMemory(date: $0.date, image: UIImage(data: $0.image)!, theme: $0.theme )}
    }
    
    // データを DBに保存する。
    // silentに失敗する。
    func save(_ pictureMemory: PictureMemory) async {
        let pictureMemoryData = PictureMemoryDataModel(pictureMemory)
        context.insert(pictureMemoryData)
        try? context.save()
    }
}

extension PictureMemoryRepository {
    public static let shared = PictureMemoryRepository()
}

// MARK:  DummyDataを用意するテストメソッド。あとで消す
extension PictureMemoryRepository {
//    func insertDummyDatas() async {
//        for date in getDateList() {
//            let dummy = PictureMemory(date: date, image: getRandomImage(), theme: getRandomTheme())
//            await save(dummy)
//        }
//    }
//    
//    // `gap`日 間隔で、`dummyCount`個の`Date`を返却する。(現在を基準に、`gap`日づつ遡る)
//    // e.g. [today - gap * (dummyCount), today - gap * (dummyCount + 1), ..., today]
    func getDateList() -> [Date] {
        let dummyCount = 20
        let gap = 2
        return (1..<dummyCount).compactMap { Calendar.current.date(byAdding: .day, value: -gap * $0, to: .now)}
    }
//    
//    func getRandomImage() -> UIImage {
//        let imageNames: [String] = ["cat","cat.fill", "cat.circle", "cat.circle.fill"]
//        let imageName = imageNames.randomElement()!
//        return UIImage(systemName: imageName)!
//    }
//    
//    func getRandomTheme() -> Theme {
//        let themes: [Theme] = [
//            .init(category: .eating("eating"), question: "Q: Eating", answer: "A: Eating"),
//            .init(category: .playing("playing"), question: "Q: playing", answer: "A: playing"),
//            .init(category: .sleeping("sleeping"), question: "Q: sleeping", answer: "A: sleepgin"),
//            .init(category: .trouble("trouble"), question: "Q: trouble", answer: "A: trouble"),
//            .init(category: .selfie("selfie"), question: "Q: selfie", answer: "A: selfie")
//        ]
//        return themes.randomElement()!
//    }
}

extension PictureMemoryRepository {
    func insertDummyDataForDemo() async {
        let eatingDummy = await generateDataForEating()
        let playingDummy = await generateDataForPlaying()
        let sleepginDummy = await generateDataForSleeping()
    ()
        let troubleDummy = await generateDataForTrouble()
        let selfieDummy = await generateDataForSelfie()
        
        // Category毎の偏りがないように、randomに並び替える。日付は順番になるように更新する。
        for (date, dummy) in zip(getDateList(), (eatingDummy + playingDummy + sleepginDummy + troubleDummy + selfieDummy).shuffled()) {
            let aDummy = PictureMemory(date: date, image: dummy.image, theme: dummy.theme)
            await save(aDummy)
        }
    }
    
    func generateDataForEating() async -> [PictureMemory] {
        let dummy1 = PictureMemory(date: .now, image: UIImage(named: "eating1")!, theme: .init(category: .eating("#今日のお昼ご飯"), question: "何を食べたの？", answer: "大好きなカツオのキャットフード"))
        let dummy2 = PictureMemory(date: .now, image: UIImage(named: "eating2")!, theme: .init(category: .eating("#ご褒美をあげよう"), question: "好きなご褒美は？", answer: "散歩の後の　Ciaoちゅーる　とりささみ"))
        return [dummy1, dummy2]
    }
    
    func generateDataForSleeping() async -> [PictureMemory] {
        let dummy1 = PictureMemory(date: .now, image: UIImage(named: "sleeping1")!, theme: .init(category: .sleeping("#ラブラブ添い寝"), question: "寝心地はどうだった？", answer: "珍しく朝まで一緒に寝てくれた"))
        let dummy2 = PictureMemory(date: .now, image: UIImage(named: "sleeping2")!, theme: .init(category: .sleeping("#居眠り激写"), question: "どんな表情だった？", answer: "赤ちゃんみたいに穏やかだった"))
        return [dummy1, dummy2]
    }
    func generateDataForPlaying() async -> [PictureMemory] {
        let dummy1 = PictureMemory(date: .now, image: UIImage(named: "playing1")!, theme: .init(category: .playing("#なんか走ってる"), question: "何があった？", answer: "全力で虫を追ってた"))
        let dummy2 = PictureMemory(date: .now, image: UIImage(named: "playing2")!, theme: .init(category: .playing("#溶けてた"), question: "場所はどこ？", answer: "縁側で気持ちよくなってた。溶けてた"))
        return [dummy1, dummy2]
    }
    
    func generateDataForTrouble() async -> [PictureMemory] {
        let dummy1 = PictureMemory(date: .now, image: UIImage(named: "trouble1")!, theme: .init(category: .trouble("#ご機嫌ななめ"), question: "何があった？", answer: "わからない、構ってくれない、、、"))
        let dummy2 = PictureMemory(date: .now, image: UIImage(named: "trouble2")!, theme: .init(category: .trouble("#スーパーうんちタイム"), question: "機嫌はどんな？", answer: "今日は元気もりもり"))
        return [dummy1, dummy2]
    }
    
    func generateDataForSelfie() async -> [PictureMemory] {
        let dummy1 = PictureMemory(date: .now, image: UIImage(named: "selfie1")!, theme: .init(category: .selfie("#みんなでパシャリ"), question: "誰と一緒？", answer: "久しぶりに姉と再会!❤️"))
        return [dummy1]
    }
}
