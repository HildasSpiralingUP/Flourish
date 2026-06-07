import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        Group {
            if !vm.hasAcceptedDisclaimer {
                DisclaimerView()
            } else if vm.isMeditating {
                MeditationView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: vm.hasAcceptedDisclaimer)
        .animation(.easeInOut(duration: 0.35), value: vm.isMeditating)
    }
}
