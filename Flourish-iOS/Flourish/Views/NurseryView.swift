import SwiftUI

struct NurseryView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Affirmation
                if vm.showAffirmation {
                    AffirmationBanner(text: vm.todayAffirmation)
                }

                WaterCard()
                StepsInfoCard()

                if !vm.readyPots.isEmpty {
                    SectionHeader("✅ Ready to plant (\(vm.readyPots.count))")
                    ForEach(vm.readyPots) { pot in
                        PotCard(pot: pot)
                    }
                }

                if !vm.growingPots.isEmpty {
                    SectionHeader("🌱 Growing (\(vm.growingPots.count))")
                    ForEach(vm.growingPots) { pot in
                        PotCard(pot: pot)
                    }
                }

                NewPotPicker()
            }
            .padding(16)
        }
    }
}

// MARK: - Affirmation Banner

struct AffirmationBanner: View {
    @Environment(AppViewModel.self) private var vm
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("✨").font(.body)
            VStack(alignment: .leading, spacing: 2) {
                Text("TODAY'S AFFIRMATION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "#1b5e20"))
                    .kerning(0.5)
                Text(text)
                    .font(.callout)
                    .foregroundStyle(Color(hex: "#33691e"))
                    .lineSpacing(3)
            }
            Spacer()
            Button { withAnimation { vm.showAffirmation = false } } label: {
                Text("×").foregroundStyle(Color(hex: "#a5d6a7")).font(.title3)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "#50a050").opacity(0.08), radius: 6, y: 2)
    }
}

// MARK: - Water Card

struct WaterCard: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("💧 Water your plants")
                        .font(.callout).fontWeight(.bold)
                        .foregroundStyle(Color(hex: "#1565c0"))
                    Text("Each glass waters all nursery pots")
                        .font(.caption).foregroundStyle(Color(hex: "#42a5f5"))
                }
                Spacer()
                Button { vm.addWaterGlass() } label: {
                    Text("+ Glass 💧")
                        .font(.callout).fontWeight(.bold)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color(hex: "#1976d2"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            // Water bubbles
            HStack(spacing: 4) {
                ForEach(0..<vm.waterGoal, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(i < vm.waterGlasses ? Color(hex: "#1976d2") : Color(hex: "#bbdefb"))
                        .frame(height: 20)
                        .overlay(Text(i < vm.waterGlasses ? "💧" : "").font(.system(size: 10)))
                        .animation(.spring(duration: 0.3), value: vm.waterGlasses)
                }
            }

            Text("\(vm.waterGlasses)/\(vm.waterGoal) glasses today\(vm.waterGlasses >= vm.waterGoal ? " · Goal reached! 🎉" : "")")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color(hex: "#1565c0"))
        }
        .padding(14)
        .background(Color(hex: "#e3f2fd"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Steps Info Card

struct StepsInfoCard: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        HStack(spacing: 12) {
            Text("👟").font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(vm.syncedSteps.formatted()) steps from iPhone")
                    .font(.callout).fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#388e3c"))
                Text("Go to the Coins tab to convert steps → coins & plant food")
                    .font(.caption).foregroundStyle(Color(hex: "#81c784"))
            }
        }
        .padding(12)
        .background(Color(hex: "#f1f8e9"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Pot Card

struct PotCard: View {
    @Environment(AppViewModel.self) private var vm
    let pot: Pot

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Pot illustration
            PotIllustration(emoji: pot.currentEmoji)
                .frame(width: 52, height: 62)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(pot.type.name)
                        .font(.callout).fontWeight(.heavy)
                        .foregroundStyle(Color(hex: "#2d5a27"))
                    Spacer()
                    Text("Stage \(pot.currentStage + 1)/4")
                        .font(.caption).foregroundStyle(Color(hex: "#81c784"))
                }

                // Steps bar
                GrowthBar(
                    icon: "👟",
                    label: "Steps",
                    current: pot.stepsAccumulated,
                    max: pot.type.stepsRequired,
                    fraction: pot.stepFraction,
                    color: Color(hex: "#43a047"),
                    background: Color(hex: "#e8f5e9"),
                    warning: pot.limitingFactor == .steps
                )
                // Water bar
                GrowthBar(
                    icon: "💧",
                    label: "Water",
                    current: pot.waterAccumulated,
                    max: pot.type.waterRequired,
                    fraction: pot.waterFraction,
                    color: Color(hex: "#1976d2"),
                    background: Color(hex: "#e3f2fd"),
                    warning: pot.limitingFactor == .water
                )

                if pot.isReady {
                    Button { vm.transplantPot(pot) } label: {
                        Text("🌳 Plant in Garden")
                            .font(.callout).fontWeight(.heavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#43a047"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 2)
                }
            }

            Button { vm.removePot(pot) } label: {
                Image(systemName: "xmark").foregroundStyle(Color(.systemGray3)).font(.body)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(pot.isReady ? Color(hex: "#f1f8e9") : Color(hex: "#fafff8"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(pot.isReady ? Color(hex: "#43a047") : Color(hex: "#e8f5e9"), lineWidth: pot.isReady ? 2 : 1.5)
        )
    }
}

struct GrowthBar: View {
    let icon: String
    let label: String
    let current: Int
    let max: Int
    let fraction: Double
    let color: Color
    let background: Color
    let warning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("\(icon) \(label)").font(.system(size: 10))
                Spacer()
                Text("\(current.formatted()) / \(max.formatted())\(warning ? " ← needs more" : "")")
                    .font(.system(size: 10))
            }
            .foregroundStyle(warning ? Color(hex: "#e65100") : Color(.secondaryLabel))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 99)
                        .fill(background)
                    RoundedRectangle(cornerRadius: 99)
                        .fill(color)
                        .frame(width: geo.size.width * fraction)
                        .animation(.easeInOut(duration: 0.4), value: fraction)
                }
            }
            .frame(height: 5)
        }
    }
}

struct PotIllustration: View {
    let emoji: String

    var body: some View {
        ZStack(alignment: .bottom) {
            // Pot body
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#CD853F"))
                    .frame(width: 36, height: 24)
                Rectangle().fill(Color(hex: "#A0522D")).frame(width: 28, height: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            // Plant
            Text(emoji)
                .font(.system(size: 26))
                .offset(y: -24)
        }
    }
}

// MARK: - New Pot Picker

struct NewPotPicker: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        VStack(alignment: .leading, spacing: 10) {
            Text("🌱 Start a new pot")
                .font(.callout).fontWeight(.bold)
                .foregroundStyle(Color(hex: "#558b2f"))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                ForEach(PlantType.allCases) { type in
                    Button { vm.selectedSeedType = type } label: {
                        VStack(spacing: 3) {
                            Text(type.fullGrowthEmoji).font(.system(size: 22))
                            Text(type.name).font(.system(size: 9, weight: .bold)).foregroundStyle(Color(hex: "#388e3c"))
                            if type.coinCost > 0 {
                                Text("🪙\(type.coinCost)").font(.system(size: 9, weight: .bold)).foregroundStyle(Color(hex: "#f9a825"))
                            }
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(vm.selectedSeedType == type ? Color(hex: "#c8e6c9") : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(vm.selectedSeedType == type ? Color(hex: "#43a047") : Color(hex: "#e8f5e9"), lineWidth: vm.selectedSeedType == type ? 2 : 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: vm.selectedSeedType)
                }
            }

            let sel = vm.selectedSeedType
            Text("\(sel.description) · 👟\(sel.stepsRequired.formatted()) steps · 💧\(sel.waterRequired) glasses")
                .font(.caption).italic()
                .foregroundStyle(Color(hex: "#8d9e7a"))

            Button { vm.startPot(type: vm.selectedSeedType) } label: {
                Text("Plant \(vm.selectedSeedType.name)\(vm.selectedSeedType.coinCost > 0 ? " · 🪙\(vm.selectedSeedType.coinCost)" : " · Free")")
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#43a047"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(14)
        .background(Color(hex: "#f9fbe7"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#c5e1a5").opacity(0.8), lineWidth: 1.5, dash: [6]))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack {
            Text(text).font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#2d5a27"))
            Spacer()
        }
    }
}
