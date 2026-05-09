import Foundation
import XCTest
import StageDesignerDomain
@testable import StageDesignerPersistence

final class SQLiteNotesRepositoryTests: XCTestCase {
    private func makeTemporaryDatabasePath() -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "stage-designer-notes-test-\(UUID().uuidString).sqlite"
        return tempDir.appendingPathComponent(fileName).path
    }

    private func setupDatabase() throws -> SQLiteDatabase {
        let db = try SQLiteDatabase(path: makeTemporaryDatabasePath())

        try db.execute(sql: """
        CREATE TABLE IF NOT EXISTS stage (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          discipline_label TEXT NOT NULL DEFAULT '',
          location TEXT NOT NULL DEFAULT '',
          notes TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL
        );
        """)

        try db.execute(sql: """
        CREATE TABLE IF NOT EXISTS checklist_item (
          id TEXT PRIMARY KEY,
          stage_id TEXT NOT NULL,
          text TEXT NOT NULL,
          is_done INTEGER NOT NULL CHECK (is_done IN (0, 1)),
          updated_at TEXT NOT NULL
        );
        """)

        try db.execute(sql: """
        CREATE TABLE IF NOT EXISTS run_note (
          id TEXT PRIMARY KEY,
          stage_id TEXT NOT NULL,
          text TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
        """)

        return db
    }

    func testChecklistInsertAndFetch() throws {
        let db = try setupDatabase()
        let stageRepo = SQLiteStageRepository(database: db)
        let notesRepo = SQLiteNotesRepository(database: db)

        let stage = Stage(title: "Checklist Stage")
        try stageRepo.upsertStage(stage)

        let item = ChecklistItem(stageId: stage.id, text: "Confirm barrel placement")
        try notesRepo.upsertChecklistItem(item)

        let fetched = try notesRepo.fetchChecklist(stageId: stage.id)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.text, "Confirm barrel placement")
    }

    func testRunNoteInsertAndFetch() throws {
        let db = try setupDatabase()
        let stageRepo = SQLiteStageRepository(database: db)
        let notesRepo = SQLiteNotesRepository(database: db)

        let stage = Stage(title: "Run Notes Stage")
        try stageRepo.upsertStage(stage)

        let note = RunNote(stageId: stage.id, text: "Dry run complete")
        try notesRepo.appendRunNote(note)

        let fetched = try notesRepo.fetchRunNotes(stageId: stage.id)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.text, "Dry run complete")
    }
}
