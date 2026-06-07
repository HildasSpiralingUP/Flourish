import SwiftUI

struct GardenTabView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        VStack(spacing: 10) {
            Text("✨ Drag your plants and decorations anywhere!")
                .font(.caption).foregroundStyle(Color(hex: "#81c784"))
                .padding(.top, 12)

            GardenCanvas()
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .aspectRatio(1.46, contentMode: .fit)

            Text("\(vm.gardenItems.count) item\(vm.gardenItems.count == 1 ? "" : "s") · Everything sways gently in the breeze 🌿")
                .font(.caption).foregroundStyle(Color(.systemGray3))
                .padding(.bottom, 12)
        }
    }
}

// MARK: - Canvas

struct GardenCanvas: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Ground
                LinearGradient(
                    colors: [Color(hex: "#4CAF50"), Color(hex: "#388E3C")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))

                // Night stars
                if vm.skyMode.isNight {
                    ForEach(0..<20, id: \.self) { i in
                        Circle()
                            .fill(.white)
                            .frame(width: 3, height: 3)
                            .position(
                                x: geo.size.width  * (Double((i * 17 + 4) % 94) / 100),
                                y: geo.size.height * (Double((i * 11 + 1) % 45) / 100)
                            )
                            .opacity(Double.random(in: 0.4...1.0))
                    }
                }

                // Grass blades
                ForEach(0..<12, id: \.self) { i in
                    Text("🌾").font(.system(size: 15))
                        .opacity(0.3)
                        .position(
                            x: geo.size.width  * (Double((i * 15 + 4) % 88) / 100),
                            y: geo.size.height * (Double((i * 17 + 5) % 78) / 100)
                        )
                }

                // Empty state
                if vm.gardenItems.isEmpty {
                    VStack(spacing: 8) {
                        Text("🌱").font(.largeTitle).opacity(0.45)
                        Text("Transplant plants from the Nursery to see them grow here!")
                            .font(.caption).foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }

                // Garden items
                ForEach(vm.gardenItems) { item in
                    DraggableGardenItem(item: item, canvasSize: geo.size)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.14), radius: 16, y: 4)
        }
    }
}

// MARK: - Draggable Item

struct DraggableGardenItem: View {
    @Environment(AppViewModel.self) private var vm
    let item: GardenItem
    let canvasSize: CGSize

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    private var position: CGPoint {
        CGPoint(
            x: item.xFraction * canvasSize.width,
            y: item.yFraction * canvasSize.height
        )
    }

    var body: some View {
        Text(item.emoji)
            .font(.system(size: 32))
            .shadow(color: .black.opacity(0.18), radius: 4, y: 3)
            .scaleEffect(isDragging ? 1.15 : 1.0)
            .animation(.spring(duration: 0.2), value: isDragging)
            .position(
                x: position.x + dragOffset.width,
                y: position.y + dragOffset.height
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        isDragging = false
                        let newX = (position.x + value.translation.width) / canvasSize.width
                        let newY = (position.y + value.translation.height) / canvasSize.height
                        vm.moveGardenItem(
                            id: item.id,
                            xFraction: max(0.05, min(0.92, newX)),
                            yFraction: max(0.08, min(0.88, newY))
                        )
                        dragOffset = .zero
                        vm.save()
                    }
            )
    }
}
