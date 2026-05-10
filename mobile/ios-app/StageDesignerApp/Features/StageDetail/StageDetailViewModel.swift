import Foundation
import StageDesignerApplication
import StageDesignerDomain

@MainActor
final class StageDetailViewModel: ObservableObject {
    @Published private(set) var stage: Stage?
    @Published private(set) var checklist: [ChecklistItem] = []
    @Published private(set) var runNotes: [RunNote] = []
    @Published var titleDraft: String = ""
    @Published var checklistDraft: String = ""
    @Published var runNoteDraft: String = ""
    @Published var exportPreviewText: String?
    @Published var lastExportPathMessage: String?
    @Published var shareFileURLs: [URL] = []
    @Published var isShowingShareSheet: Bool = false
    @Published var isBusy: Bool = false
    @Published var errorMessage: String?

    private let stageId: UUID
    private let listStagesUseCase: ListStagesUseCase
    private let updateStageMetadataUseCase: UpdateStageMetadataUseCase
    private let addStageElementUseCase: AddStageElementUseCase
    private let addChecklistItemUseCase: AddChecklistItemUseCase
    private let toggleChecklistItemUseCase: ToggleChecklistItemUseCase
    private let addRunNoteUseCase: AddRunNoteUseCase
    private let getStageNotesSnapshotUseCase: GetStageNotesSnapshotUseCase
    private let exportStageUseCase: ExportStageUseCase
    private let stageVisualExportService: StageVisualExportService
    private let defaultAssetId: UUID?

    init(stageId: UUID, container: AppContainer) {
        self.stageId = stageId
        self.listStagesUseCase = container.listStagesUseCase
        self.updateStageMetadataUseCase = container.updateStageMetadataUseCase
        self.addStageElementUseCase = container.addStageElementUseCase
        self.addChecklistItemUseCase = container.addChecklistItemUseCase
        self.toggleChecklistItemUseCase = container.toggleChecklistItemUseCase
        self.addRunNoteUseCase = container.addRunNoteUseCase
        self.getStageNotesSnapshotUseCase = container.getStageNotesSnapshotUseCase
        self.exportStageUseCase = container.exportStageUseCase
        self.stageVisualExportService = container.stageVisualExportService
        self.defaultAssetId = container.defaultAssetId

        refresh()
    }

    func refresh() {
        do {
            stage = try listStagesUseCase.execute().first(where: { $0.id == stageId })
            titleDraft = stage?.title ?? ""
            let snapshot = try getStageNotesSnapshotUseCase.execute(stageId: stageId)
            checklist = snapshot.checklist
            runNotes = snapshot.runNotes
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load stage detail."
        }
    }

    func saveTitle() {
        guard let stage else {
            errorMessage = "Stage not found."
            return
        }

        do {
            isBusy = true
            defer { isBusy = false }
            _ = try updateStageMetadataUseCase.execute(
                UpdateStageMetadataInput(
                    stageId: stage.id,
                    title: titleDraft,
                    disciplineLabel: stage.disciplineLabel,
                    location: stage.location,
                    notes: stage.notes
                )
            )
            refresh()
        } catch {
            errorMessage = "Failed to save title."
        }
    }

    func addSampleElement() {
        guard let defaultAssetId else {
            errorMessage = "No default asset configured."
            return
        }

        do {
            isBusy = true
            defer { isBusy = false }
            _ = try addStageElementUseCase.execute(
                AddStageElementInput(stageId: stageId, assetId: defaultAssetId, x: Double((stage?.elements.count ?? 0) + 1), y: 1)
            )
            refresh()
        } catch {
            errorMessage = "Failed to add element."
        }
    }

    func addChecklistItem() {
        let text = checklistDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        do {
            isBusy = true
            defer { isBusy = false }
            _ = try addChecklistItemUseCase.execute(stageId: stageId, text: text)
            checklistDraft = ""
            refresh()
        } catch {
            errorMessage = "Failed to add checklist item."
        }
    }

    func toggleChecklist(_ item: ChecklistItem) {
        do {
            isBusy = true
            defer { isBusy = false }
            _ = try toggleChecklistItemUseCase.execute(stageId: stageId, itemId: item.id, isDone: !item.isDone)
            refresh()
        } catch {
            errorMessage = "Failed to update checklist item."
        }
    }

    func addRunNote() {
        let text = runNoteDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        do {
            isBusy = true
            defer { isBusy = false }
            _ = try addRunNoteUseCase.execute(stageId: stageId, text: text)
            runNoteDraft = ""
            refresh()
        } catch {
            errorMessage = "Failed to add run note."
        }
    }

    func export(format: ExportFormat) {
        do {
            isBusy = true
            defer { isBusy = false }
            let result = try exportStageUseCase.execute(stageId: stageId)
            switch format {
            case .json:
                exportPreviewText = result.json
            case .csv:
                exportPreviewText = result.csv
            }
            lastExportPathMessage = nil
            errorMessage = nil
        } catch {
            errorMessage = "Failed to export stage."
        }
    }

    func exportVisualFiles() {
        guard let stage else {
            errorMessage = "Stage not found."
            return
        }

        do {
            isBusy = true
            defer { isBusy = false }
            let outputDir = FileManager.default.temporaryDirectory.appendingPathComponent("stage-visual-exports")
            let baseName = "stage-\(stage.id.uuidString.lowercased())"
            let result = try stageVisualExportService.export(stage: stage, outputDirectory: outputDir, baseFileName: baseName)
            shareFileURLs = [result.pdfURL, result.pngURL, result.jpegURL]
            isShowingShareSheet = true
            lastExportPathMessage = "Saved PDF/PNG/JPEG to \(result.pdfURL.deletingLastPathComponent().path)"
            errorMessage = nil
        } catch {
            errorMessage = "Failed to export visual files."
        }
    }

    func dismissShareSheet() {
        isShowingShareSheet = false
    }
}
