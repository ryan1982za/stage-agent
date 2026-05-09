import Foundation
import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

struct AppContainer {
    let listStagesUseCase: ListStagesUseCase
    let createStageUseCase: CreateStageUseCase
    let updateStageMetadataUseCase: UpdateStageMetadataUseCase
    let deleteStageUseCase: DeleteStageUseCase
    let exportStageUseCase: ExportStageUseCase
    let writeStageExportFilesUseCase: WriteStageExportFilesUseCase
    let addStageElementUseCase: AddStageElementUseCase
    let addChecklistItemUseCase: AddChecklistItemUseCase
    let toggleChecklistItemUseCase: ToggleChecklistItemUseCase
    let addRunNoteUseCase: AddRunNoteUseCase
    let getStageNotesSnapshotUseCase: GetStageNotesSnapshotUseCase
    let stageVisualExportService: StageVisualExportService
    let defaultAssetId: UUID?

    static func makeDefault() -> AppContainer {
        do {
            let dbPath = try defaultDatabasePath()
            let schemaPath = try resolveDefaultSchemaPath()
            return try makeSQLiteBacked(dbPath: dbPath, schemaPath: schemaPath)
        } catch {
            return makeInMemoryBacked()
        }
    }

    private static func makeInMemoryBacked() -> AppContainer {
        let stageRepository = InMemoryStageRepository()
        let assetRepository = InMemoryAssetRepository(seedAssets: BuiltInAssets.v1Catalog)
        let notesRepository = InMemoryNotesRepository()

        let exportUseCase = ExportStageUseCase(stageRepository: stageRepository, assetRepository: assetRepository, notesRepository: notesRepository)

        return AppContainer(
            listStagesUseCase: ListStagesUseCase(stageRepository: stageRepository),
            createStageUseCase: CreateStageUseCase(stageRepository: stageRepository),
            updateStageMetadataUseCase: UpdateStageMetadataUseCase(stageRepository: stageRepository),
            deleteStageUseCase: DeleteStageUseCase(stageRepository: stageRepository),
            exportStageUseCase: exportUseCase,
            writeStageExportFilesUseCase: WriteStageExportFilesUseCase(exportStageUseCase: exportUseCase),
            addStageElementUseCase: AddStageElementUseCase(stageRepository: stageRepository, assetRepository: assetRepository),
            addChecklistItemUseCase: AddChecklistItemUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            toggleChecklistItemUseCase: ToggleChecklistItemUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            addRunNoteUseCase: AddRunNoteUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            getStageNotesSnapshotUseCase: GetStageNotesSnapshotUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            stageVisualExportService: StageVisualExportService(),
            defaultAssetId: BuiltInAssets.v1Catalog.first?.id
        )
    }

    private static func defaultDatabasePath() throws -> String {
        let fm = FileManager.default
        let baseDirectory = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fm.temporaryDirectory
        let appDirectory = baseDirectory.appendingPathComponent("StageAgent", isDirectory: true)
        try fm.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        return appDirectory.appendingPathComponent("stage-agent-v1.sqlite").path
    }

    private static func resolveDefaultSchemaPath() throws -> String {
        let fm = FileManager.default

        if let bundled = Bundle.main.url(forResource: "sqlite-schema-v1", withExtension: "sql") {
            return bundled.path
        }

        let cwd = fm.currentDirectoryPath
        let candidates = [
            "\(cwd)/docs/contracts/sqlite-schema-v1.sql",
            "\(cwd)/../docs/contracts/sqlite-schema-v1.sql",
            "\(cwd)/../../docs/contracts/sqlite-schema-v1.sql"
        ]

        for candidate in candidates where fm.fileExists(atPath: candidate) {
            return candidate
        }

        throw SQLiteBootstrapError.schemaFileMissing
    }

    static func makeSQLiteBacked(dbPath: String, schemaPath: String) throws -> AppContainer {
        let bootstrap = try SQLiteBootstrap.fromFile(at: schemaPath)
        let database = try SQLiteDatabase(path: dbPath)

        try database.beginTransaction()
        do {
            for statement in bootstrap.migrationStatements() {
                try database.execute(sql: statement)
            }
            try database.commit()
        } catch {
            try? database.rollback()
            throw error
        }

        let stageRepository = SQLiteStageRepository(database: database)
        let assetRepository = InMemoryAssetRepository(seedAssets: BuiltInAssets.v1Catalog)
        let notesRepository = SQLiteNotesRepository(database: database)

        let exportUseCase = ExportStageUseCase(stageRepository: stageRepository, assetRepository: assetRepository, notesRepository: notesRepository)

        return AppContainer(
            listStagesUseCase: ListStagesUseCase(stageRepository: stageRepository),
            createStageUseCase: CreateStageUseCase(stageRepository: stageRepository),
            updateStageMetadataUseCase: UpdateStageMetadataUseCase(stageRepository: stageRepository),
            deleteStageUseCase: DeleteStageUseCase(stageRepository: stageRepository),
            exportStageUseCase: exportUseCase,
            writeStageExportFilesUseCase: WriteStageExportFilesUseCase(exportStageUseCase: exportUseCase),
            addStageElementUseCase: AddStageElementUseCase(stageRepository: stageRepository, assetRepository: assetRepository),
            addChecklistItemUseCase: AddChecklistItemUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            toggleChecklistItemUseCase: ToggleChecklistItemUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            addRunNoteUseCase: AddRunNoteUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            getStageNotesSnapshotUseCase: GetStageNotesSnapshotUseCase(stageRepository: stageRepository, notesRepository: notesRepository),
            stageVisualExportService: StageVisualExportService(),
            defaultAssetId: BuiltInAssets.v1Catalog.first?.id
        )
    }
}
