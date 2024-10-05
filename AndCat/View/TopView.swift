import SwiftUI

struct TopListView<Stream: TopViewStreamType>: View {
    @StateObject var viewStream: Stream

    public init(viewStream: Stream) {
        _viewStream = StateObject(wrappedValue: viewStream)
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Text("Home") }
            CalendarView()
                .tabItem { Text("Calendar") }
            MemorialView()
                .tabItem { Text("Memorial") }
        }
    }
}

#Preview {
    TopListView(viewStream: TopViewStream.shared)
}
