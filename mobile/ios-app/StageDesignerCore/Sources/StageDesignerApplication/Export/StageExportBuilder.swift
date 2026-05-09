import Foundation
import StageDesignerDomain

public enum StageExportBuilderError: Error, Equatable {
    case missingAssetDefinition(assetId: UUID)
}

public final class StageExportBuilder {
    private let isoFormatter: ISO8601DateFormatter

    public init() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.isoFormatter = formatter
    }

    public func buildExport(stage: Stage, allAssets: [AssetDefinition], exportedAt: Date = Date()) throws -> StageExportV1 {
        let assetsById = Dictionary(uniqueKeysWithValues: allAssets.map { ($0.id, $0) })
        let usedAssetIds = Set(stage.elements.map { $0.assetId })

        for assetId in usedAssetIds where assetsById[assetId] == nil {
            throw StageExportBuilderError.missingAssetDefinition(assetId: assetId)
        }

        let exportStage = StageExportStage(
            id: stage.id.uuidString.lowercased(),
            title: stage.title,
            disciplineLabel: stage.disciplineLabel,
            location: stage.location,
            notes: stage.notes,
            updatedAt: isoFormatter.string(from: stage.updatedAt)
        )

        let exportAssets = usedAssetIds
            .compactMap { assetsById[$0] }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map {
                StageExportAsset(
                    id: $0.id.uuidString.lowercased(),
                    name: $0.name,
                    category: $0.category,
                    isCustom: $0.isCustom,
                    defaultWidth: $0.defaultWidth,
                    defaultHeight: $0.defaultHeight,
                    notes: $0.notes
                )
            }

        let exportElements = stage.elements
            .sorted { $0.zIndex < $1.zIndex }
            .map {
                StageExportElement(
                    id: $0.id.uuidString.lowercased(),
                    stageId: $0.stageId.uuidString.lowercased(),
                    assetId: $0.assetId.uuidString.lowercased(),
                    x: $0.x,
                    y: $0.y,
                    width: $0.width,
                    height: $0.height,
                    rotationDeg: $0.rotationDeg,
                    zIndex: $0.zIndex
                )
            }

        let exportChecklist = stage.checklist
            .sorted { $0.updatedAt > $1.updatedAt }
            .map {
                StageExportChecklistItem(
                    id: $0.id.uuidString.lowercased(),
                    stageId: $0.stageId.uuidString.lowercased(),
                    text: $0.text,
                    isDone: $0.isDone,
                    updatedAt: isoFormatter.string(from: $0.updatedAt)
                )
            }

        let exportRunNotes = stage.runNotes
            .sorted { $0.createdAt > $1.createdAt }
            .map {
                StageExportRunNote(
                    id: $0.id.uuidString.lowercased(),
                    stageId: $0.stageId.uuidString.lowercased(),
                    text: $0.text,
                    createdAt: isoFormatter.string(from: $0.createdAt)
                )
            }

        return StageExportV1(
            exportedAt: isoFormatter.string(from: exportedAt),
            stage: exportStage,
            assets: exportAssets,
            elements: exportElements,
            checklist: exportChecklist,
            runNotes: exportRunNotes
        )
    }

    public func toPrettyJSON(_ export: StageExportV1) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(export)
        guard let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }

    public func toCSV(stage: Stage, allAssets: [AssetDefinition]) throws -> String {
        let assetsById = Dictionary(uniqueKeysWithValues: allAssets.map { ($0.id, $0) })

        var lines: [String] = [
            "element_id,stage_id,asset_id,asset_name,asset_category,x,y,width,height,rotation_deg,z_index"
        ]

        for element in stage.elements.sorted(by: { $0.zIndex < $1.zIndex }) {
            guard let asset = assetsById[element.assetId] else {
                throw StageExportBuilderError.missingAssetDefinition(assetId: element.assetId)
            }

            let row = [
                element.id.uuidString.lowercased(),
                element.stageId.uuidString.lowercased(),
                element.assetId.uuidString.lowercased(),
                escapeCSV(asset.name),
                escapeCSV(asset.category),
                String(element.x),
                String(element.y),
                String(element.width),
                String(element.height),
                String(element.rotationDeg),
                String(element.zIndex)
            ].joined(separator: ",")

            lines.append(row)
        }

        return lines.joined(separator: "\n")
    }

    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }
}
