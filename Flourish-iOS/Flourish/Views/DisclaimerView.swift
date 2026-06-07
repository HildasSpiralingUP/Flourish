import SwiftUI

struct DisclaimerView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var promise1 = false
    @State private var promise2 = false

    private var ready: Bool { promise1 && promise2 }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#e8f5e9"), Color(hex: "#f1f8e9"), Color(hex: "#e0f7fa")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🌿").font(.system(size: 54))
                        Text("Welcome to Step Garden")
                            .font(.custom("", size: 26)).fontWeight(.heavy)
                            .foregroundStyle(Color(hex: "#2d5a27"))
                        Text("A gentle note before you begin")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "#81c784"))
                    }

                    // Message card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This app is **not** intended to encourage or promote any form of disordered eating or unhealthy behaviors. It is a gentle space for movement, hydration, and self-care.")
                            .font(.callout).foregroundStyle(Color(hex: "#33691e")).lineSpacing(4)
                        Divider().background(Color(hex: "#c5e1a5"))
                        Text("I believe with my whole heart that **every person has full autonomy over their body and the choices they make in their life.** My only hope is that you choose health and happiness — because that is what I wish for you. 💚")
                            .font(.callout).foregroundStyle(Color(hex: "#33691e")).lineSpacing(4)
                        Divider().background(Color(hex: "#c5e1a5"))
                        Text("Everyone has a beautiful garden in their heart. We all grow a little differently — but we are all still **deserving of love,** especially the love that comes from one's self. 🌸")
                            .font(.callout).foregroundStyle(Color(hex: "#33691e")).lineSpacing(4)
                    }
                    .padding(18)
                    .background(Color(hex: "#f9fbe7"))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#c5e1a5"), lineWidth: 1.5))

                    // Promises
                    PromiseCheckbox(
                        checked: $promise1,
                        text: "I promise to take good care of myself — my body, my mind, and my spirit. I will treat myself with kindness and patience as I grow. 🌱"
                    )
                    PromiseCheckbox(
                        checked: $promise2,
                        text: "I promise to take good care of those around me, because life is about people. We all bloom in our own time, and I will celebrate that in myself and others. 🌸"
                    )

                    // Enter button
                    Button {
                        if ready {
                            vm.hasAcceptedDisclaimer = true
                            vm.save()
                        }
                    } label: {
                        Text(ready ? "Enter My Garden 🌿" : "Please check both boxes to continue")
                            .fontWeight(.heavy)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(ready ? LinearGradient(colors: [Color(hex: "#66bb6a"), Color(hex: "#2e7d32")], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color(.systemGray5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundStyle(ready ? .white : Color(.systemGray))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: ready ? Color(hex: "#66bb6a").opacity(0.4) : .clear, radius: 10, y: 4)
                    }
                    .disabled(!ready)
                    .animation(.easeInOut(duration: 0.25), value: ready)
                }
                .padding(24)
            }
        }
    }
}

struct PromiseCheckbox: View {
    @Binding var checked: Bool
    let text: String

    var body: some View {
        Button { checked.toggle() } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(checked ? Color(hex: "#43a047") : Color(.systemGray3), lineWidth: 2.5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(checked ? Color(hex: "#43a047") : .white)
                        )
                        .frame(width: 24, height: 24)
                    if checked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 2)

                Text(text)
                    .font(.callout)
                    .foregroundStyle(checked ? Color(hex: "#2d5a27") : Color(.secondaryLabel))
                    .fontWeight(checked ? .bold : .regular)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
            }
            .padding(14)
            .background(checked ? Color(hex: "#e8f5e9") : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(checked ? Color(hex: "#43a047") : Color(.systemGray4), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: checked)
    }
}
