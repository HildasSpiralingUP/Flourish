import SwiftUI

struct MainTabView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        ZStack(alignment: .top) {
            // Sky background
            skyBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: vm.skyMode)

            VStack(spacing: 0) {
                // Header
                HeaderView()

                // Sky mode picker
                SkyModePicker()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)

                // Main content card
                TabContentView()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 12)
                    .shadow(color: .black.opacity(0.08), radius: 20, y: 4)

                Spacer(minLength: 0)
            }
            .padding(.top, 8)

            // Toast
            if let msg = vm.toastMessage {
                ToastView(emoji: vm.toastEmoji, message: msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(duration: 0.3), value: vm.toastMessage)
                    .zIndex(999)
            }
        }
    }

    private var skyBackground: some View {
        LinearGradient(
            colors: [Color(hex: vm.skyMode.skyTop), Color(hex: "#b8e4f7")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Header

struct HeaderView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Step Garden 🌿")
                    .font(.title2).fontWeight(.heavy)
                    .foregroundStyle(Color(hex: "#2d5a27"))
                Text("Walk · Drink · Grow")
                    .font(.caption).foregroundStyle(Color(hex: "#81c784"))
            }

            Spacer()

            // Affirmation button
            if vm.showAffirmation {
                Button {
                    withAnimation { vm.showAffirmation = false }
                } label: {
                    Text("✨")
                }
            }

            HStack(spacing: 12) {
                VStack(spacing: 1) {
                    Text("🪙 \(vm.coins)")
                        .font(.headline).fontWeight(.heavy)
                        .foregroundStyle(Color(hex: "#f9a825"))
                    Text("coins").font(.system(size: 9)).foregroundStyle(.secondary)
                }
                VStack(spacing: 1) {
                    Text("👟 \(vm.syncedSteps.formatted())")
                        .font(.headline).fontWeight(.heavy)
                        .foregroundStyle(Color(hex: "#43a047"))
                    Text("steps").font(.system(size: 9)).foregroundStyle(.secondary)
                }
                Button {
                    vm.isMeditating = true
                } label: {
                    Text("🧘 Meditate")
                        .font(.caption).fontWeight(.bold)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(LinearGradient(colors: [Color(hex: "#a5d6a7"), Color(hex: "#4db6ac")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }
}

// MARK: - Sky Mode Picker

struct SkyModePicker: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SkyMode.allCases, id: \.self) { mode in
                    Button {
                        vm.skyMode = mode
                        vm.save()
                    } label: {
                        Text("\(mode.icon) \(mode.displayName)")
                            .font(.caption).fontWeight(.bold)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(vm.skyMode == mode ? Color.white.opacity(0.95) : Color.white.opacity(0.35))
                            .foregroundStyle(vm.skyMode == mode ? Color(hex: "#2d5a27") : .white)
                            .clipShape(Capsule())
                    }
                    .animation(.easeInOut(duration: 0.2), value: vm.skyMode)
                }
            }
        }
    }
}

// MARK: - Tab Content

struct TabContentView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(AppViewModel.Tab.allCases, id: \.self) { tab in
                    Button {
                        vm.selectedTab = tab
                    } label: {
                        VStack(spacing: 2) {
                            Text(tab.icon).font(.system(size: 18))
                            Text(tab.label).font(.system(size: 9))
                            if tab == .nursery && !vm.readyPots.isEmpty {
                                Text("\(vm.readyPots.count)")
                                    .font(.system(size: 8, weight: .heavy))
                                    .padding(.horizontal, 5)
                                    .background(Color.red)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(vm.selectedTab == tab ? .white : Color.clear)
                        .foregroundStyle(vm.selectedTab == tab ? Color(hex: "#2d5a27") : Color(hex: "#81c784"))
                        .fontWeight(vm.selectedTab == tab ? .heavy : .semibold)
                        .overlay(alignment: .bottom) {
                            if vm.selectedTab == tab {
                                Rectangle()
                                    .fill(Color(hex: "#43a047"))
                                    .frame(height: 2.5)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.18), value: vm.selectedTab)
                }
            }
            .background(Color(hex: "#fafff8"))

            Divider().background(Color(hex: "#f1f8e9"))

            // Tab body
            Group {
                switch vm.selectedTab {
                case .nursery: NurseryView()
                case .garden:  GardenTabView()
                case .coins:   CoinsView()
                case .shop:    ShopView()
                case .health:  HealthTabView()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Toast

struct ToastView: View {
    let emoji: String
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
            Text(message).fontWeight(.bold)
        }
        .font(.callout)
        .foregroundStyle(Color(hex: "#2d5a27"))
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        .padding(.top, 12)
    }
}
