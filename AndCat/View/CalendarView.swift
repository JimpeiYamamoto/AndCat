//
//  CalenderView.swift
//  AndCat
//
//  Created by 山本 迅平 on 10/5/24.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        BasicMultiDatePicker()
    }
}

#Preview {
    CalendarView()
}

struct BasicMultiDatePicker: View {

    // 選択日付を保持するプロパティ
    @State private var dates: Set<DateComponents> = []

    var body: some View {

        MultiDatePicker("複数の日付選択", selection: $dates)
    }
}
