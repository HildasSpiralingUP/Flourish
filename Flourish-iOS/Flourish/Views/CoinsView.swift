import SwiftUI

struct CoinsView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Coin balance
                VStack(spacing: 6) {
                    Text("🪙")
                        .font(.system(size: 48))
                    Text("\(vm.coins) coins")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(Color(hex: "#f57f17"))
                    Text("Spend on seeds and decorations in the Shop")
                        .font(.caption).foregroundStyle(Color(hex: "#f9a825"))
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(LinearGradient(colors: [Color(hex: "#fff8e1"), Color(hex: "#fff3cd")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#ffe082"), lineWidth: 1.5))

                // Convert steps
                VStack(alignment: .leading, spacing: 14) {
                    Text("Convert steps to coins")
                        .font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#2d5a27"))
                    Text("Every 100 steps = 1 coin. Converting also feeds your nursery plants!")
                        .font(.caption).foregroundStyle(Color(hex: "#81c784"))

                    HStack(spacing: 12) {
                        StatBox(label: "Steps to convert", value: "👟 \(vm.pendingSteps.formatted())", color: Color(hex: "#43a047"))
                        StatBox(label: "You will earn",    value: "🪙 \(vm.pendingSteps / 100)",      color: Color(hex: "#f9a825"))
                    }

                    Button { vm.convertSteps() } label: {
                        let canConvert = vm.pendingSteps >= 100
                        Text(canConvert
                             ? "Convert \(vm.pendingSteps.formatted()) steps → 🪙\(vm.pendingSteps / 100)"
                             : "Walk more to convert steps!")
                            .fontWeight(.heavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canConvert
                                ? LinearGradient(colors: [Color(hex: "#ffca28"), Color(hex: "#ff8f00")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                            .foregroundStyle(canConvert ? .white : Color(.systemGray))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: canConvert ? Color(hex: "#ff8f00").opacity(0.3) : .clear, radius: 10, y: 4)
                    }
                    .disabled(vm.pendingSteps < 100)

                    HStack(spacing: 8) {
                        Text("💡")
                        Text("Steps sync automatically from your iPhone's Health app — no manual logging needed!")
                            .font(.caption).foregroundStyle(Color(hex: "#558b2f"))
                    }
                    .padding(10)
                    .background(.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(16)
                .background(Color(hex: "#f1f8e9"))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Earning guide
                VStack(alignment: .leading, spacing: 0) {
                    Text("Earning guide")
                        .font(.callout).fontWeight(.bold).foregroundStyle(Color(hex: "#2d5a27"))
                        .padding(.bottom, 10)

                    ForEach([
                        ("👟", "100 steps = 1 coin",      "Walk daily to earn"),
                        ("💧", "Log water glasses",        "Grow plants faster"),
                        ("🌿", "Rare plants",              "Take more steps and water to grow"),
                    ], id: \.1) { icon, title, sub in
                        HStack(spacing: 12) {
                            Text(icon).font(.title3).frame(width: 30, alignment: .center)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(title).font(.callout).fontWeight(.bold).foregroundStyle(Color(hex: "#2d5a27"))
                                Text(sub).font(.caption).foregroundStyle(Color(hex: "#81c784"))
                            }
                        }
                        .padding(.vertical, 8)
                        Divider().background(Color(hex: "#f1f8e9"))
                    }
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#e8f5e9"), lineWidth: 1.5))
            }
            .padding(16)
        }
    }
}

struct StatBox: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label).font(.system(size: 11)).foregroundStyle(.secondary)
            Text(value).font(.title3).fontWeight(.heavy).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
