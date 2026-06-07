import SwiftUI

@main
struct FlourishApp: App {
    @State private var vm = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(vm)
        }
    }
}
