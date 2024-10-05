//
//  CalenderView.swift
//  AndCat
//
//  Created by 山本 迅平 on 10/5/24.
//

import SwiftUI

struct CalendarView: View {
    var calendar = Calendar.current

    // 過去12か月分の月を取得
    var pastYearMonths: [Date] {
        var months = [Date]()
        for i in 0..<12 {
            if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                months.append(month)
            }
        }
        return months
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "E6EAED")
                ScrollView {
                    VStack(spacing: 10) {
                        // 各月のカレンダーを表示
                        ForEach(pastYearMonths.reversed(), id: \.self) { month in
                            MonthlyCalendarView(selectedDate: month, viewStream: CalenderViewStream.shared)
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
    }
}

struct MonthlyCalendarView<Stream: CalendarViewStreamType>: View {
    @StateObject var viewStream: Stream
    var selectedDate: Date
    private var calendar = Calendar.current
    
    init(selectedDate: Date, viewStream: Stream) {
        self.selectedDate = selectedDate
        _viewStream = StateObject(wrappedValue: viewStream)
    }
    
    var body: some View {
        VStack {
            // 月名を表示
            HStack {
                Text("\(monthName)")
                    .foregroundStyle(Color(hex: "0A3049"))
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                Spacer()
            }
            
            // 曜日名を表示
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .foregroundStyle(Color(hex: "0A3049"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // カレンダーの日付を表示
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                // 月の1日が始まる曜日まで空白セルを追加
                ForEach(0..<startDayIndex, id: \.description) { _ in
                    Text("")
                }
                
                // 月の日数を表示
                ForEach(daysInMonth, id: \.self) { day in
                    ZStack {
                        if viewStream.output.isPresentLoadingView {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        } else {
                            if let dateDict,
                               let pictureMemory = dateDict[day] {
                                NavigationLink(destination: DateMemoryView(pictureMemory: pictureMemory)) {
                                    Image(uiImage: pictureMemory.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                }
                            }
                            Text("\(day)")
                                .foregroundStyle(Color(hex: "0A3049"))
                                .frame(width: 50, height: 50)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewStream.action(input: .onAppear)
            }
        }
        .padding()
    }
    
    // 曜日名（日曜日から）
    var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.shortWeekdaySymbols
    }

    // 月名を取得
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: selectedDate)
    }
    
    // yyyyMMをIntで取得
    var yearAndMonthInt: Int {
        // 日付をフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let yearAndMonthString = formatter.string(from: selectedDate)
        return Int(yearAndMonthString)!
    }
    
    // 日付のDictを取得
    var dateDict: Dictionary<Int, CalenderViewStreamModel.PictureMemory>? {
        if let dateDict = viewStream.output.pictureMemoryDict[yearAndMonthInt] {
            return dateDict
        }
        return nil
    }
    
   
    // 月の1日が始まる曜日（0=日曜日, 1=月曜日, ...）
    var startDayIndex: Int {
        guard let firstDay = getDate(day: 1) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDay)
        return weekday - 1 // 日曜日を0、月曜日を1として計算
    }

    // 月の日数を取得
    var daysInMonth: [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        return Array(range)
    }

    // 特定の日の正確なDateを取得
    func getDate(day: Int) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: selectedDate)
        components.day = day
        return calendar.date(from: components)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
