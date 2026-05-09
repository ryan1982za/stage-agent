import Foundation
import StageDesignerApplication
import StageDesignerDomain

@MainActor
final class StageListViewModel: ObservableObject {
    @Published private(set) var stages: [Stage] = []
    @Published var draftTitle: String = ""
    @Published var errorMessage: String?
    @Published var exportPreviewText: String?
    @Published var lastExportPathMessage: String?

    private let listStagesUseCase: ListStagesUseCase
    private let createStageUseCase: CreateStageUseCase
    private let updateStageMetadataUseCase: UpdateStageMetadataUseCase
    private let deleteStageUseCase: DeleteStageUseCase
    private let exportStageUseCase: ExportStageUseCase
    private let writeStageExportFilesUseCase: WriteStageExportFilesUseCase
    private let addStageElementUseCase: AddStageElementUseCase
    private let defaultAssetId: UUID?
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        self.listStagesUseCase = container.listStagesUseCase
        self.createStageUseCase = container.createStageUseCase
        self.updateStageMetadataUseCase = container.updateStageMetadataUseCase
        self.deleteStageUseCase = container.deleteStageUseCase
        self.exportStageUseCase = container.exportStageUseCase
        self.writeStageExportFilesUseCase = container.writeStageExportFilesUseCase
        self.addStageElementUseCase = container.addStageElementUseCase
        self.defaultAssetId = container.defaultAssetId

        refresh()
    }

    func refresh() {
        do {
            stages = try listStagesUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load stages."
        }
    }

    func createStage() {
        let title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            errorMessage = "Title is required."
            return
        }

        do {
            _ = try createStageUseCase.execute(CreateStageInput(title: title))
            draftTitle = ""
            refresh()
        } catch {
            errorMessage = "Failed to create stage."
        }
    }

    func deleteStage(id: UUID) {
        do {
            try deleteStageUseCase.execute(stageId: id)
            refresh()
        } catch {
            errorMessage = "Failed to delete stage."
        }
    }

    func exportStage(id: UUID, format: ExportFormat) {
        do {
            let result = try exportStageUseCase.execute(stageId: id)
            switch format {
            case .json:
                exportPreviewText = result.json
            case .csv:
                exportPreviewText = result.csv
            }
            errorMessage = nil
        } catch {
            errorMessage = "Failed to export stage."
        }
    }

    func exportStageToFiles(id: UUID) {
        do {
            let outputDir = FileManager.default.temporaryDirectory.appendingPathComponent("stage-exports")
            let base = "stage-\(id.uuidString.lowercased())"
            let result = try writeStageExportFilesUseCase.execute(stageId: id, outputDirectory: outputDir, baseFileName: base)
            lastExportPathMessage = "Saved JSON and CSV to \(result.jsonURL.deletingLastPathComponent().path)"
            errorMessage = nil
        } catch {
            errorMessage = "Failed to write export files."
        }
    }

    func addSampleElement(stageId: UUID) {
        guard let defaultAssetId else {
            errorMessage = "No default asset available."
            return
        }

        do {
            _ = try addStageElementUseCase.execute(
                AddStageElementInput(stageId: stageId, assetId: defaultAssetId, x: 1, y: 1)
            )
            refresh()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to add stage element."
        }
    }

    func renameStage(id: UUID, newTitle: String) {
        do {
            guard let stage = try listStagesUseCase.execute().first(where: { $0.id == id }) else {
                errorMessage = "Stage not found."
                return
            }

            _ = try updateStageMetadataUseCase.execute(
                UpdateStageMetadataInput(
                    stageId: id,
                    title: newTitle,
                    disciplineLabel: stage.disciplineLabel,
                    location: stage.location,
                    notes: stage.notes
                )
            )

            refresh()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to rename stage."
        }
    }

    func makeDetailViewModel(stageId: UUID) -> StageDetailViewModel {
        StageDetailViewModel(stageId: stageId, container: container)
    }
}

enum ExportFormat {
    case json
    case csv
}
