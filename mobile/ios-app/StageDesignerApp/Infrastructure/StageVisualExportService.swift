import Foundation
import StageDesignerDomain
import UIKit

struct StageVisualExportResult {
    let pdfURL: URL
    let pngURL: URL
    let jpegURL: URL
}

struct StageVisualExportService {
    func export(stage: Stage, outputDirectory: URL, baseFileName: String) throws -> StageVisualExportResult {
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let canvasSize = makeCanvasSize(stage: stage)
        let pdfURL = outputDirectory.appendingPathComponent("\(baseFileName).pdf")
        let pngURL = outputDirectory.appendingPathComponent("\(baseFileName).png")
        let jpegURL = outputDirectory.appendingPathComponent("\(baseFileName).jpg")

        let imageRenderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = imageRenderer.image { context in
            drawStage(stage, in: context.cgContext, canvasSize: canvasSize)
        }

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: canvasSize))
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            drawStage(stage, in: context.cgContext, canvasSize: canvasSize)
        }

        if let pngData = image.pngData() {
            try pngData.write(to: pngURL, options: .atomic)
        }

        if let jpegData = image.jpegData(compressionQuality: 0.9) {
            try jpegData.write(to: jpegURL, options: .atomic)
        }

        try pdfData.write(to: pdfURL, options: .atomic)

        return StageVisualExportResult(pdfURL: pdfURL, pngURL: pngURL, jpegURL: jpegURL)
    }

    private func makeCanvasSize(stage: Stage) -> CGSize {
        let minWidth: CGFloat = 1200
        let minHeight: CGFloat = 800

        let maxX = stage.elements.map { $0.x + $0.width }.max() ?? 0
        let maxY = stage.elements.map { $0.y + $0.height }.max() ?? 0

        let width = max(minWidth, CGFloat(maxX * 60) + 240)
        let height = max(minHeight, CGFloat(maxY * 60) + 240)

        return CGSize(width: width, height: height)
    }

    private func drawStage(_ stage: Stage, in cgContext: CGContext, canvasSize: CGSize) {
        let bounds = CGRect(origin: .zero, size: canvasSize)
        cgContext.setFillColor(UIColor.systemBackground.cgColor)
        cgContext.fill(bounds)

        let margin: CGFloat = 80
        let drawable = bounds.insetBy(dx: margin, dy: margin)

        let maxX = max(stage.elements.map { $0.x + $0.width }.max() ?? 10, 10)
        let maxY = max(stage.elements.map { $0.y + $0.height }.max() ?? 10, 10)

        let scaleX = drawable.width / CGFloat(maxX)
        let scaleY = drawable.height / CGFloat(maxY)
        let scale = min(scaleX, scaleY)

        drawGrid(in: cgContext, rect: drawable)

        let title = stage.title.isEmpty ? "Untitled Stage" : stage.title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 34),
            .foregroundColor: UIColor.label
        ]
        NSString(string: title).draw(at: CGPoint(x: margin, y: 20), withAttributes: titleAttrs)

        let subtitle = "Elements: \(stage.elements.count)"
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.secondaryLabel
        ]
        NSString(string: subtitle).draw(at: CGPoint(x: margin, y: 60), withAttributes: subtitleAttrs)

        for element in stage.elements.sorted(by: { $0.zIndex < $1.zIndex }) {
            let rect = CGRect(
                x: drawable.minX + CGFloat(element.x) * scale,
                y: drawable.minY + CGFloat(element.y) * scale,
                width: max(CGFloat(element.width) * scale, 8),
                height: max(CGFloat(element.height) * scale, 8)
            )

            let color = colorForElement(zIndex: element.zIndex)
            cgContext.saveGState()
            cgContext.translateBy(x: rect.midX, y: rect.midY)
            cgContext.rotate(by: CGFloat(element.rotationDeg) * .pi / 180)

            let rotatedRect = CGRect(x: -rect.width / 2, y: -rect.height / 2, width: rect.width, height: rect.height)
            cgContext.setFillColor(color.withAlphaComponent(0.25).cgColor)
            cgContext.fill(rotatedRect)
            cgContext.setStrokeColor(color.cgColor)
            cgContext.setLineWidth(2)
            cgContext.stroke(rotatedRect)

            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 13),
                .foregroundColor: UIColor.label
            ]
            let label = NSString(string: "#\(element.zIndex)")
            let labelRect = CGRect(x: rotatedRect.minX + 4, y: rotatedRect.minY + 4, width: rotatedRect.width - 8, height: 20)
            label.draw(in: labelRect, withAttributes: labelAttrs)
            cgContext.restoreGState()
        }
    }

    private func drawGrid(in cgContext: CGContext, rect: CGRect) {
        cgContext.setStrokeColor(UIColor.systemGray5.cgColor)
        cgContext.setLineWidth(1)

        let spacing: CGFloat = 40
        var x = rect.minX
        while x <= rect.maxX {
            cgContext.move(to: CGPoint(x: x, y: rect.minY))
            cgContext.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += spacing
        }

        var y = rect.minY
        while y <= rect.maxY {
            cgContext.move(to: CGPoint(x: rect.minX, y: y))
            cgContext.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }

        cgContext.strokePath()
    }

    private func colorForElement(zIndex: Int) -> UIColor {
        let hue = CGFloat((zIndex % 12 + 12) % 12) / 12.0
        return UIColor(hue: hue, saturation: 0.75, brightness: 0.85, alpha: 1)
    }
}
