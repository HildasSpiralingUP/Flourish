import SwiftUI

struct HealthTabView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var weightInput = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                WaterSection()
                WeightSection(weightInput: $weightInput)
                StepsSection()
            }
            .padding(16)
        }
    }
}

// MARK: - Water Section

struct WaterSection: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("💧 Water Intake")
                .font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#1565c0"))

            HStack(spacing: 4) {
                ForEach(0..<vm.waterGoal, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(i < vm.waterGlasses ? Color(hex: "#1976d2") : Color(hex: "#bbdefb"))
                        .frame(height: 28)
                        .overlay(Text(i < vm.waterGlasses ? "💧" : "").font(.caption))
                        .animation(.spring(duration: 0.3), value: vm.waterGlasses)
                }
            }

            HStack {
                Text("\(vm.waterGlasses)/\(vm.waterGoal)\(vm.waterGlasses >= vm.waterGoal ? " · 🎉 Goal reached!" : "")")
                    .font(.callout).fontWeight(.semibold).foregroundStyle(Color(hex: "#1565c0"))
                Spacer()
                Button { vm.addWaterGlass() } label: {
                    Text("+ Glass")
                        .fontWeight(.bold).font(.callout)
                        .padding(.horizontal, 18).padding(.vertical, 8)
                        .background(Color(hex: "#1976d2"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(14)
        .background(Color(hex: "#e3f2fd"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Weight Section

struct WeightSection: View {
    @Environment(AppViewModel.self) private var vm
    @Binding var weightInput: String

    private var recentLog: [WeightEntry] { Array(vm.weightLog.suffix(7)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("⚖️ Weight Tracker")
                .font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#6a1b9a"))

            HStack(spacing: 8) {
                TextField("Enter weight (lbs)", text: $weightInput)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#ce93d8"), lineWidth: 1.5))
                    .onSubmit { logWeight() }

                Button { logWeight() } label: {
                    Text("Log")
                        .fontWeight(.bold)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(Color(hex: "#8e24aa"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            // Bar chart
            if !recentLog.isEmpty {
                let vals = recentLog.map(\.value)
                let mn   = (vals.min() ?? 0) - 2
                let mx   = (vals.max() ?? 1) + 2

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(recentLog.enumerated()), id: \.element.id) { idx, entry in
                        let frac = (entry.value - mn) / (mx - mn)
                        let barH = max(8.0, (1.0 - frac) * 50 + 10)
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(idx == recentLog.count - 1 ? Color(hex: "#8e24aa") : Color(hex: "#ce93d8"))
                                .frame(height: barH)
                            Text(entry.date.formatted(.dateTime.day()))
                                .font(.system(size: 9)).foregroundStyle(Color(hex: "#9c27b0"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 70)
                .animation(.easeInOut(duration: 0.4), value: recentLog.count)
            }

            if vm.weightLog.count >= 2 {
                let first = vm.weightLog.first!.value
                let last  = vm.weightLog.last!.value
                Text(last < first
                     ? "📉 Down \(String(format: "%.1f", first - last)) lbs since you started"
                     : "📊 Keep logging to see your trend")
                    .font(.callout).fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "#6a1b9a"))
            }
        }
        .padding(14)
        .background(Color(hex: "#f3e5f5"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func logWeight() {
        guard let v = Double(weightInput), v > 0 else { return }
        vm.logWeight(v)
        weightInput = ""
    }
}

// MARK: - Steps Section

struct StepsSection: View {
    @Environment(AppViewModel.self) private var vm

    private let dailyGoal = 10_000

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("👟 Steps Today (from iPhone)")
                .font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#1b5e20"))

            Text(vm.syncedSteps.formatted())
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(Color(hex: "#2e7d32"))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "#c8e6c9")).frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(colors: [Color(hex: "#66bb6a"), Color(hex: "#2e7d32")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * min(Double(vm.syncedSteps) / Double(dailyGoal), 1.0), height: 10)
                        .animation(.easeInOut(duration: 0.5), value: vm.syncedSteps)
                }
            }
            .frame(height: 10)

            Text(vm.syncedSteps >= dailyGoal
                 ? "🎉 Daily goal reached!"
                 : "\((dailyGoal - vm.syncedSteps).formatted()) steps to daily goal")
                .font(.caption).foregroundStyle(Color(hex: "#81c784"))

            Button {
                Task { await vm.refreshSteps() }
            } label: {
                Label("Refresh from Health", systemImage: "arrow.clockwise")
                    .font(.caption).fontWeight(.semibold)
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Color(hex: "#e8f5e9"))
                    .foregroundStyle(Color(hex: "#2e7d32"))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(Color(hex: "#e8f5e9"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
