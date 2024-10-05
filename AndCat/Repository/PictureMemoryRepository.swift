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
//        Task {
//            await insertDummyDatas()
//        }
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
    func insertDummyDatas() async {
        for date in getDateList() {
            let dummy = PictureMemory(date: date, image: getRandomImage(), theme: getRandomTheme())
            await save(dummy)
        }
    }
    
    // `gap`日 間隔で、`dummyCount`個の`Date`を返却する。(現在を基準に、`gap`日づつ遡る)
    // e.g. [today - gap * (dummyCount), today - gap * (dummyCount + 1), ..., today]
    func getDateList() -> [Date] {
        let dummyCount = 20
        let gap = 2
        return (0..<dummyCount).compactMap { Calendar.current.date(byAdding: .day, value: -gap * $0, to: .now)}
    }
    
    func getRandomImage() -> UIImage {
        let imageNames: [String] = ["cat","cat.fill", "cat.circle", "cat.circle.fill"]
        let imageName = imageNames.randomElement()!
        return UIImage(systemName: imageName)!
    }
    
    func getRandomTheme() -> Theme {
        let themes: [Theme] = [
            .init(category: .eating("eating"), question: "Q: Eating", answer: "A: Eating"),
            .init(category: .playing("playing"), question: "Q: playing", answer: "A: playing"),
            .init(category: .sleeping("sleeping"), question: "Q: sleeping", answer: "A: sleepgin")
        ]
        return themes.randomElement()!
    }
}
