import SwiftUI

@main
struct AndCatApp: App {
    var body: some Scene {
        WindowGroup {
            TopListView(viewStream: TopViewStream.shared)
        }
    }
}
