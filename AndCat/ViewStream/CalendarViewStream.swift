//
//  CalendarViewStream.swift
//  AndCat
//
//  Created by 上別縄祐也 on 2024/10/05.
//

import Foundation
import UIKit

public protocol CalendarViewStreamType: ViewStreamType
where Output == CalenderViewStreamModel.Output,
      Input == CalenderViewStreamModel.Input,
      State == CalenderViewStreamModel.State
{}

public final class CalenderViewStream: CalendarViewStreamType {
    public var state = CalenderViewStreamModel.State()
    private let useCase: CalenderViewUseCaseType

    @Published public var output = CalenderViewStreamModel.Output(
        pictureMemoryDict: [:],
        isPresentLoadingView: true
    )
    
    public init(useCase: CalenderViewUseCaseType) {
        self.useCase = useCase
    }

    @MainActor
    public func action(
        input: CalenderViewStreamModel.Input
    ) async {
        switch input {
        case .onAppear:
            output.isPresentLoadingView = true
            defer {
                output.isPresentLoadingView = false
            }

            // 非同期処理のみバックグランドスレッドで実行するように指定
            let fetchResult = await Task.detached(priority: .background) {
                await self.useCase.fetchPictureMemoryList(first: Calendar.current.date(byAdding: .month, value: -11, to: Date())!, last: Date())
            }.value

            switch fetchResult {
            case let .success(pictureMemoryList):
                var yearAndMonthDict: Dictionary<Int, Dictionary<Int, CalenderViewStreamModel.PictureMemory>> = [:]
                for pictureMemory in pictureMemoryList {
                    // 日付をIntに変換
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMM"
                    let yearAndMonthInt = Int(formatter.string(from: pictureMemory.date))!
                    formatter.dateFormat = "dd"
                    let dateInt = Int(formatter.string(from: pictureMemory.date))!
                    
                    let pictureMemory = CalenderViewStreamModel.PictureMemory(date: pictureMemory.date, image: pictureMemory.image, theme: pictureMemory.theme)
                    if var dict = yearAndMonthDict[yearAndMonthInt] {
                        dict.updateValue(pictureMemory, forKey: dateInt)
                        yearAndMonthDict.updateValue(dict, forKey: yearAndMonthInt)
                    } else {
                        let dict = [dateInt: pictureMemory]
                        yearAndMonthDict.updateValue(dict, forKey: yearAndMonthInt)
                    }
                }
                output.pictureMemoryDict = yearAndMonthDict
            }
        }
    }
}

public enum CalenderViewStreamModel {
    // viewからの得られるイベントを管理するenum
    public enum Input {
        case onAppear
    }

    // Viewへ描画する値を管理するStruct
    public struct Output {
        public var pictureMemoryDict: Dictionary<Int,Dictionary<Int, PictureMemory>>
        public var isPresentLoadingView: Bool

        public init(
            pictureMemoryDict: Dictionary<Int,Dictionary<Int, PictureMemory>>,
            isPresentLoadingView: Bool
        ) {
            self.pictureMemoryDict = pictureMemoryDict
            self.isPresentLoadingView = isPresentLoadingView
        }
    }
    
    public struct State {
        
    }
}

extension CalenderViewStreamModel {
    public struct PictureMemory {
        let date: Date
        let image: UIImage
        let theme: Theme
    }
}

extension Category {
    func getString() -> String {
          switch self {
          case .eating(let value),
               .sleeping(let value),
               .playing(let value):
              return value
          }
    }
}

extension CalenderViewStream {
    public static let shared = CalenderViewStream(useCase: CalenderViewUseCase.shared)
}
