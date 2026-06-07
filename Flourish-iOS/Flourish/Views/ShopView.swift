import SwiftUI

struct ShopView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("🪙 \(vm.coins) coins available · Decorations drop straight into your garden!")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "#81c784"))

                // Seeds
                Text("🌱 Seeds")
                    .font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#2d5a27"))

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(PlantType.allCases) { type in
                        SeedCard(type: type)
                    }
                }

                // Decorations
                Text("🏡 Decorations")
                    .font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#2d5a27"))

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(DecorationID.allCases) { deco in
                        DecoCard(deco: deco)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct SeedCard: View {
    let type: PlantType

    var sizeLabel: String {
        switch type {
        case .blossom, .tree: return "large"
        case .rose, .sunflower: return "medium"
        default: return "small"
        }
    }

    var sizeLabelColor: Color {
        switch sizeLabel {
        case "large":  return Color(hex: "#e65100")
        case "medium": return Color(hex: "#2e7d32")
        default:       return Color(hex: "#6a1b9a")
        }
    }

    var sizeLabelBg: Color {
        switch sizeLabel {
        case "large":  return Color(hex: "#fff8e1")
        case "medium": return Color(hex: "#e8f5e9")
        default:       return Color(hex: "#f3e5f5")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(type.fullGrowthEmoji).font(.system(size: 28))
                Spacer()
                Text(sizeLabel)
                    .font(.system(size: 9, weight: .heavy))
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(sizeLabelBg)
                    .foregroundStyle(sizeLabelColor)
                    .clipShape(Capsule())
            }
            Text(type.name).font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#2d5a27"))
            Text("👟\(type.stepsRequired.formatted()) · 💧\(type.waterRequired)gl")
                .font(.system(size: 10)).foregroundStyle(Color(hex: "#8d9e7a"))
            Text(type.coinCost > 0 ? "🪙 \(type.coinCost)" : "✨ Free")
                .font(.callout).fontWeight(.bold)
                .foregroundStyle(type.coinCost > 0 ? Color(hex: "#f9a825") : Color(hex: "#43a047"))
        }
        .padding(12)
        .background(Color(hex: "#fafff8"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#e8f5e9"), lineWidth: 1.5))
    }
}

struct DecoCard: View {
    @Environment(AppViewModel.self) private var vm
    let deco: DecorationID

    private var def: DecorationDef { deco.definition }
    private var canAfford: Bool { vm.coins >= def.cost }

    var body: some View {
        Button { vm.placeDeco(deco) } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(def.emoji).font(.system(size: 28))
                Text(def.name).font(.callout).fontWeight(.heavy).foregroundStyle(Color(hex: "#2d5a27"))
                Text("🪙 \(def.cost)").font(.callout).fontWeight(.bold).foregroundStyle(Color(hex: "#f9a825"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(hex: "#fafff8"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#e8f5e9"), lineWidth: 1.5))
            .opacity(canAfford ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!canAfford)
    }
}
