import SwiftUI

struct TopListView<Stream: TopViewStreamType>: View {
    @StateObject var viewStream: Stream
    @State private var selectedTab: Int = 0

        var selectedTabTitle: String {
            switch selectedTab {
            case 0:
                return "お題"
            case 1:
                return "カレンダー"
            case 2:
                return "メモリアル"
            default:
                return ""
            }
        }

    public init(viewStream: Stream) {
        _viewStream = StateObject(wrappedValue: viewStream)

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
    }

    var body: some View {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    HomeView(viewStream: HomeViewStream.shared)
                        .tabItem { Text("Home") }
                        .tag(0)
                    CalendarView()
                        .tabItem { Text("Calendar") }
                        .tag(1)
                    MemorialView()
                        .tabItem { Text("Memorial") }
                        .tag(2)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(selectedTabTitle)
                            .foregroundStyle(Color.black)
                            .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
}

#Preview {
    TopListView(viewStream: TopViewStream.shared)
}
