import SwiftUI

struct MeditationView: View {
    @Environment(AppViewModel.self) private var vm

    enum Phase { case intro, ready, breathing, done }

    @State private var phase: Phase = .intro
    @State private var selectedMinutes: Int = 5
    @State private var elapsed: Int = 0
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathCount: Int = 0
    @State private var isBig: Bool = false
    @State private var breathTimer: Timer? = nil
    @State private var elapsedTimer: Timer? = nil

    enum BreathPhase {
        case inhale, hold, exhale
        var label: String {
            switch self { case .inhale: "Breathe In"; case .hold: "Hold"; case .exhale: "Breathe Out" }
        }
        var hint: String {
            switch self {
            case .inhale: return "Fill your belly first, then your chest."
            case .hold:   return "Hold gently. Feel the stillness."
            case .exhale: return "Let it all go slowly. Belly falls first."
            }
        }
        var color: Color {
            switch self { case .inhale: Color(hex: "#81c784"); case .hold: Color(hex: "#64b5f6"); case .exhale: Color(hex: "#ffb74d") }
        }
        var duration: Int { switch self { case .inhale: 4; case .hold: 2; case .exhale: 6 } }
    }

    private var skyGradient: some View {
        LinearGradient(
            colors: [Color(hex: vm.skyMode.skyTop), Color(hex: "#203a43")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            skyGradient

            VStack {
                // Close
                HStack {
                    Spacer()
                    Button { stopAndClose() } label: {
                        Text("✕ Close")
                            .font(.caption).fontWeight(.bold)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(.white.opacity(0.25))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .padding([.top, .trailing], 18)
                }

                switch phase {
                case .intro:     introScreen
                case .ready:     readyScreen
                case .breathing: breathingScreen
                case .done:      doneScreen
                }

                Spacer()
            }
        }
        .onDisappear { stopTimers() }
    }

    // MARK: - Intro

    private var introScreen: some View {
        VStack(spacing: 20) {
            Text("🧘").font(.system(size: 60))
            Text("Garden Meditation")
                .font(.title2).fontWeight(.heavy).foregroundStyle(.white)
            Text("Diaphragmatic breathing calms your nervous system, reduces stress, and connects you to the present moment.")
                .font(.callout).foregroundStyle(.white.opacity(0.9)).multilineTextAlignment(.center).lineSpacing(3)

            VStack(alignment: .leading, spacing: 10) {
                Text("How to breathe with your diaphragm")
                    .font(.callout).fontWeight(.bold).foregroundStyle(.white)
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity)
                ForEach([
                    ("1", "Place one hand on your chest, one on your belly.", "👋"),
                    ("2", "As you inhale, your belly rises — not your chest.", "🫁"),
                    ("3", "Exhale slowly and completely. Feel your belly fall.", "🌬️"),
                    ("4", "Your chest stays mostly still throughout.", "✨"),
                ], id: \.0) { n, t, e in
                    HStack(alignment: .top, spacing: 10) {
                        Text(n)
                            .font(.system(size: 12, weight: .heavy))
                            .frame(width: 24, height: 24)
                            .background(.white.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                        Text("\(e) \(t)").font(.callout).foregroundStyle(.white.opacity(0.95)).lineSpacing(3)
                    }
                }
            }
            .padding(18)
            .background(.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            // Duration picker
            HStack(spacing: 10) {
                ForEach([5, 10, 15], id: \.self) { mins in
                    Button { selectedMinutes = mins } label: {
                        Text("\(mins) min")
                            .fontWeight(.heavy)
                            .padding(.horizontal, 22).padding(.vertical, 10)
                            .background(selectedMinutes == mins ? .white : .white.opacity(0.25))
                            .foregroundStyle(selectedMinutes == mins ? Color(hex: "#2d5a27") : .white)
                            .clipShape(Capsule())
                    }
                }
            }

            Button { phase = .ready } label: {
                Text("I'm Ready to Begin 🌿")
                    .fontWeight(.heavy).frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.white.opacity(0.25))
                    .overlay(Capsule().stroke(.white.opacity(0.6), lineWidth: 2))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
    }

    // MARK: - Ready

    private var readyScreen: some View {
        VStack(spacing: 20) {
            Text("🌸").font(.system(size: 68))
            Text("Find a comfortable position.")
                .font(.title2).fontWeight(.heavy).foregroundStyle(.white)
            Text("Sit or lie down. Place one hand on your chest, one on your belly. Close your eyes if you wish.")
                .font(.callout).foregroundStyle(.white.opacity(0.85)).multilineTextAlignment(.center).lineSpacing(3)
                .padding(.horizontal, 30)
            Button { startBreathing() } label: {
                Text("Begin 🌬️")
                    .font(.title3).fontWeight(.heavy)
                    .padding(.horizontal, 40).padding(.vertical, 16)
                    .background(.white)
                    .foregroundStyle(Color(hex: "#2d5a27"))
                    .clipShape(Capsule())
            }
        }
        .padding(24)
    }

    // MARK: - Breathing

    private var breathingScreen: some View {
        let total = selectedMinutes * 60
        let remaining = total - elapsed
        let mm = String(format: "%02d", remaining / 60)
        let ss = String(format: "%02d", remaining % 60)

        return VStack(spacing: 16) {
            Text("\(mm):\(ss) remaining")
                .font(.caption).fontWeight(.semibold).foregroundStyle(.white.opacity(0.7))

            // Breathing orb
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 6)
                    .frame(width: 200, height: 200)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(Double(elapsed) / Double(total), 1.0))
                    .stroke(.white.opacity(0.6), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: elapsed)

                ForEach([55, 42, 30], id: \.self) { r in
                    Circle()
                        .fill(breathPhase.color)
                        .opacity([55: 0.2, 42: 0.35, 30: 0.65][r] ?? 0.3)
                        .frame(width: Double(r) * 2, height: Double(r) * 2)
                        .scaleEffect(isBig ? 1.6 : 1.0)
                        .animation(.easeInOut(duration: Double(breathPhase.duration)), value: isBig)
                }
            }

            Text(breathPhase.label)
                .font(.title).fontWeight(.heavy).foregroundStyle(.white)
            Text(breathPhase.hint)
                .font(.callout).foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center).lineSpacing(3)
                .frame(minHeight: 44)
                .padding(.horizontal, 30)

            // Belly / chest indicators
            HStack(spacing: 14) {
                BodyIndicator(
                    emoji: "🫃",
                    label: "Belly",
                    sublabel: breathPhase != .hold ? (breathPhase == .inhale ? "Rising ↑" : "Falling ↓") : "Still",
                    active: breathPhase != .hold
                )
                BodyIndicator(emoji: "🫀", label: "Chest", sublabel: "Still", active: false)
            }

            Text("Breath \(breathCount + 1)")
                .font(.caption).foregroundStyle(.white.opacity(0.45))
        }
        .padding(24)
    }

    // MARK: - Done

    private var doneScreen: some View {
        VStack(spacing: 16) {
            Text("🌸").font(.system(size: 68))
            Text("Beautiful. 💚")
                .font(.title).fontWeight(.heavy).foregroundStyle(.white)
            Text("You just gave yourself \(selectedMinutes) minutes of pure care. Your garden — inside and out — is grateful.")
                .font(.callout).foregroundStyle(.white.opacity(0.9)).multilineTextAlignment(.center).lineSpacing(3)
                .padding(.horizontal, 30)
            Text("\(breathCount) mindful breaths completed")
                .font(.callout).foregroundStyle(.white.opacity(0.6))
            Button { stopAndClose() } label: {
                Text("Return to My Garden 🌿")
                    .fontWeight(.heavy)
                    .padding(.horizontal, 36).padding(.vertical, 14)
                    .background(.white)
                    .foregroundStyle(Color(hex: "#2d5a27"))
                    .clipShape(Capsule())
            }
        }
        .padding(24)
    }

    // MARK: - Breathing logic

    private func startBreathing() {
        phase = .breathing
        elapsed = 0
        breathCount = 0
        runBreathCycle()

        // Elapsed ticker
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1
            if elapsed >= selectedMinutes * 60 {
                stopTimers()
                withAnimation { phase = .done }
            }
        }
    }

    private func runBreathCycle() {
        withAnimation { breathPhase = .inhale; isBig = true }
        vm.audioManager.playBreathe(inhale: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard phase == .breathing else { return }
            withAnimation { breathPhase = .hold }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            guard phase == .breathing else { return }
            withAnimation { breathPhase = .exhale; isBig = false }
            vm.audioManager.playBreathe(inhale: false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            guard phase == .breathing else { return }
            breathCount += 1
            runBreathCycle()
        }
    }

    private func stopTimers() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }

    private func stopAndClose() {
        stopTimers()
        vm.isMeditating = false
    }
}

struct BodyIndicator: View {
    let emoji: String
    let label: String
    let sublabel: String
    let active: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(emoji).font(.title3)
            Text(label).font(.caption).fontWeight(.semibold).foregroundStyle(.white.opacity(0.8))
            Text(sublabel).font(.system(size: 10)).foregroundStyle(active ? .white.opacity(0.9) : .white.opacity(0.4))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(active ? .white.opacity(0.25) : .white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.5), value: active)
    }
}
