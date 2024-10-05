import SwiftUI

struct TopListView<Stream: TopViewStreamType>: View {
    @StateObject var viewStream: Stream

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
            TabView {
                HomeView(viewStream: HomeViewStream.shared)
                    .tabItem { Text("Home") }
                CalendarView()
                    .tabItem { Text("Calendar") }
                MemorialView()
                    .tabItem { Text("Memorial") }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("お題")
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
