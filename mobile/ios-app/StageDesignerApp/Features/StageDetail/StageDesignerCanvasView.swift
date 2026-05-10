import SwiftUI
import StageDesignerDomain

/// A visual 2D canvas for dragging stage elements onto a top-down view of the stage.
/// Users can:
/// - Tap an asset to select it for placement
/// - Drag onto the canvas to place it
/// - Tap placed elements to select them
/// - Long-press to move/edit selected elements
/// - Tap-and-hold gesture triggers element movement
struct StageDesignerCanvasView: View {
    @ObservedObject var viewModel: StageDetailViewModel
    @State private var selectedElementId: UUID?
    @State private var dragOffset: CGSize = .zero
    @State private var isPreparedForPlacement = false

    private let canvasWidth: CGFloat = 300
    private let canvasHeight: CGFloat = 400
    private let gridSpacing: CGFloat = 20
    private let normalizedCanvasSize: CGFloat = 2.0  // Normalized units (0 to 2.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Asset Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Asset to Place")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.availableAssets) { asset in
                            AssetPillButton(
                                asset: asset,
                                isSelected: viewModel.selectedAssetId == asset.id,
                                action: {
                                    viewModel.selectedAssetId = asset.id
                                    isPreparedForPlacement = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Canvas Area
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    // Grid background
                    Canvas { context in
                        drawGrid(in: context)
                    }
                    .background(Color(.systemBackground))

                    // Stage boundary
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                        .frame(width: canvasWidth, height: canvasHeight)

                    // Elements
                    ForEach(viewModel.stageElementRows, id: \.id) { row in
                        CanvasElementView(
                            row: row,
                            isSelected: selectedElementId == row.id,
                            canvasWidth: canvasWidth,
                            canvasHeight: canvasHeight,
                            normalizedCanvasSize: normalizedCanvasSize,
                            onTap: {
                                selectedElementId = row.id
                                isPreparedForPlacement = false
                            }
                        )
                    }
                }
                .frame(width: canvasWidth, height: canvasHeight)
                .background(Color(.systemBackground))
                .border(Color.gray.opacity(0.3), width: 1)
                .onTapGesture { location in
                    handleCanvasTap(at: location)
                }
            }

            // Instructions
            if isPreparedForPlacement {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap")
                        .foregroundStyle(.blue)
                    Text("Tap canvas to place the selected asset")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else if let elementId = selectedElementId {
                HStack(spacing: 8) {
                    Image(systemName: "hand.raised.fingers.spread")
                        .foregroundStyle(.orange)
                    Text("Long-press to edit or delete this element")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .contextMenu {
                    Button(role: .destructive) {
                        // Delete will be handled in view model
                        viewModel.deleteElement(withId: elementId)
                        selectedElementId = nil
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func drawGrid(in context: GraphicsContext) {
        var path = Path()
        let step = gridSpacing

        // Vertical lines
        for i in stride(from: 0, through: canvasWidth, by: step) {
            path.move(to: CGPoint(x: i, y: 0))
            path.addLine(to: CGPoint(x: i, y: canvasHeight))
        }

        // Horizontal lines
        for i in stride(from: 0, through: canvasHeight, by: step) {
            path.move(to: CGPoint(x: 0, y: i))
            path.addLine(to: CGPoint(x: canvasWidth, y: i))
        }

        var stroke = StrokeStyle(lineWidth: 0.5)
        stroke.dash = [4, 4]
        context.stroke(path, with: .color(Color.gray.opacity(0.2)), style: stroke)
    }

    private func handleCanvasTap(at location: CGPoint) {
        guard isPreparedForPlacement, viewModel.selectedAssetId != nil else {
            return
        }

        // Convert tap location to normalized canvas coordinates
        let normalizedX = (location.x / canvasWidth) * normalizedCanvasSize
        let normalizedY = (location.y / canvasHeight) * normalizedCanvasSize

        // Clamp to valid range
        let clampedX = max(0, min(normalizedCanvasSize - 0.3, normalizedX))
        let clampedY = max(0, min(normalizedCanvasSize - 0.3, normalizedY))

        // Add element at this canvas position
        viewModel.addElementAtCanvasPosition(x: clampedX, y: clampedY)
        isPreparedForPlacement = false
        selectedElementId = nil
    }
}

struct AssetPillButton: View {
    let asset: AssetDefinition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: assetIcon(for: asset.category))
                    .font(.system(size: 16))
                Text(asset.name)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
            }
            .frame(width: 70, height: 70)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func assetIcon(for category: String) -> String {
        switch category.lowercased() {
        case "targets": return "target"
        case "props": return "cube"
        case "boundaries": return "line.diagonal"
        case "markers": return "flag"
        default: return "square"
        }
    }
}

struct CanvasElementView: View {
    let row: StageDetailViewModel.StageElementRow
    let isSelected: Bool
    let canvasWidth: CGFloat
    let canvasHeight: CGFloat
    let normalizedCanvasSize: CGFloat
    let onTap: () -> Void

    var body: some View {
        let elementWidth = (row.width / normalizedCanvasSize) * canvasWidth
        let elementHeight = (row.height / normalizedCanvasSize) * canvasHeight
        let elementX = (row.x / normalizedCanvasSize) * canvasWidth
        let elementY = (row.y / normalizedCanvasSize) * canvasHeight

        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(colorForZIndex(row.zIndex))
                .opacity(isSelected ? 0.9 : 0.7)

            if isSelected {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Color.blue, lineWidth: 2)
            }

            VStack(spacing: 2) {
                Text(row.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("z:\(row.zIndex)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(4)
        }
        .frame(width: elementWidth, height: elementHeight)
        .position(x: elementX + elementWidth / 2, y: elementY + elementHeight / 2)
        .onTapGesture {
            onTap()
        }
    }

    private func colorForZIndex(_ zIndex: Int) -> Color {
        let hue = Double(zIndex % 10) * 0.1
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
}

#Preview {
    let container = AppContainer.makeDefault()
    let viewModel = StageDetailViewModel(stageId: UUID(), container: container)
    return StageDesignerCanvasView(viewModel: viewModel)
}
