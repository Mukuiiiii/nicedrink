import SwiftUI
import UIKit

struct DrinkPreviewCard: View {
    @Binding var order: DrinkOrder
    let stickerImage: UIImage?
    let onRandomize: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            cupVisual
                .scaleEffect(order.cupSize.previewScale)
                .frame(width: 112, height: 146)
                .animation(.spring(duration: 0.35, bounce: 0.25), value: order.cupSize)
                .animation(.easeInOut(duration: 0.25), value: order.hasCheeseFoam)
                .contextMenu {
                    Section("快速套用暗黑配方") {
                        ForEach(DrinkPreset.allPresets) { preset in
                            Button {
                                withAnimation {
                                    preset.apply(&order)
                                }
                            } label: {
                                Label(preset.title, systemImage: preset.icon)
                            }
                        }
                    }

                    Divider()

                    Button {
                        withAnimation {
                            onRandomize()
                        }
                    } label: {
                        Label("隨機暗黑特調", systemImage: "dice.fill")
                    }
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(order.trimmedDrinkName.isEmpty ? "未命名暗黑特調" : order.trimmedDrinkName)
                        .font(.headline)
                        .lineLimit(1)

                    if order.hasEcoCup {
                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .accessibilityLabel("自備環保杯")
                    }
                }

                Text("\(order.teaBase.rawValue) ・ \(order.cupSize.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(order.sweetnessLabel) / \(order.iceLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("配料：\(order.toppingsSummary)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer(minLength: 4)

                HStack(spacing: 12) {
                    Label("NT$\(order.totalPrice)", systemImage: "dollarsign.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)

                    Label("\(order.totalCalories) kcal", systemImage: "flame.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(order.totalCalories >= 1000 ? .red : .orange)
                }

                Text("長按飲料杯可套用預設配方")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var cupVisual: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 3)
                .fill(.primary.opacity(0.75))
                .frame(width: 8, height: 34)
                .rotationEffect(.degrees(10))
                .offset(x: 16, y: 2)

            VStack(spacing: 0) {
                Spacer().frame(height: 20)

                ZStack {
                    CupShape()
                        .fill(
                            LinearGradient(
                                colors: [order.topColor, order.bottomColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    if order.iceLevel > 0 {
                        iceCubesLayer
                            .offset(y: order.hasCheeseFoam ? -22 : -34)
                    }
                    
                    if order.hasCheeseFoam {
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.99, green: 0.97, blue: 0.92))
                                .frame(height: 20)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.brown.opacity(0.15), lineWidth: 1)
                                }
                            Spacer()
                        }
                        .clipShape(CupShape())
                    }
                    toppingsLayer
                        .padding(.bottom, 6)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    stickerBadge
                    CupShape()
                        .stroke(.primary.opacity(0.25), lineWidth: 2)
                }
                .frame(width: 84, height: 112)
            }

            Capsule()
                .fill(.primary.opacity(0.85))
                .frame(width: 92, height: 8)
                .offset(y: 17)
        }
    }

    private var iceCubesLayer: some View {
        let cubeCount = max(1, Int(order.iceLevel / 25))
        return HStack(spacing: 4) {
            ForEach(0..<cubeCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(.white.opacity(0.55))
                    .frame(width: 11, height: 11)
                    .rotationEffect(.degrees(Double(index * 15 - 12)))
            }
        }
    }

    private var toppingsLayer: some View {
        VStack(spacing: 2) {
            if order.puddingCount > 0 {
                HStack(spacing: 3) {
                    ForEach(0..<order.puddingCount, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.96, green: 0.78, blue: 0.28))
                            .frame(width: 14, height: 7)
                    }
                }
            }
            if order.coconutJellyCount > 0 {
                HStack(spacing: 3) {
                    ForEach(0..<min(order.coconutJellyCount * 2, 6), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.85))
                            .frame(width: 7, height: 7)
                    }
                }
            }
            if order.bobaCount > 0 {
                HStack(spacing: 3) {
                    ForEach(0..<min(order.bobaCount * 2, 7), id: \.self) { _ in
                        Circle()
                            .fill(Color(red: 0.15, green: 0.10, blue: 0.08))
                            .frame(width: 7, height: 7)
                    }
                }
            }
        }
    }

    private var stickerBadge: some View {
        VStack(spacing: 2) {
            if let stickerImage {
                Image(uiImage: stickerImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(.rect(cornerRadius: 6))
            } else {
                Text(order.trimmedDrinkName.isEmpty ? "LAB" : String(order.trimmedDrinkName.prefix(4)))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
            }
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(order.stickerBgColor)
                .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
        }
    }
}

struct CupShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset: CGFloat = 10
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
