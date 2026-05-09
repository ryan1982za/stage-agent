import Foundation
import XCTest
import StageDesignerDomain
@testable import StageDesignerPersistence

final class SQLiteStageRepositoryTests: XCTestCase {
    private func makeTemporaryDatabasePath() -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "stage-designer-test-\(UUID().uuidString).sqlite"
        return tempDir.appendingPathComponent(fileName).path
    }

    private func setupDatabase() throws -> SQLiteDatabase {
        let path = makeTemporaryDatabasePath()
        let db = try SQLiteDatabase(path: path)

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

        return db
    }

    func testUpsertAndFetchStage() throws {
        let db = try setupDatabase()
        let repo = SQLiteStageRepository(database: db)

        let stage = Stage(
            title: "Test Stage",
            disciplineLabel: "Practical",
            location: "Bay 1",
            notes: "Notes",
            updatedAt: Date()
        )

        try repo.upsertStage(stage)

        let fetched = try repo.fetchStage(id: stage.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "Test Stage")
        XCTAssertEqual(fetched?.disciplineLabel, "Practical")
    }

    func testFetchAllStagesSortedByUpdatedAtDesc() throws {
        let db = try setupDatabase()
        let repo = SQLiteStageRepository(database: db)

        let older = Stage(title: "Older", updatedAt: Date().addingTimeInterval(-7200))
        let newer = Stage(title: "Newer", updatedAt: Date())

        try repo.upsertStage(older)
        try repo.upsertStage(newer)

        let all = try repo.fetchAllStages()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all.first?.title, "Newer")
        XCTAssertEqual(all.last?.title, "Older")
    }

    func testDeleteStageRemovesRecord() throws {
        let db = try setupDatabase()
        let repo = SQLiteStageRepository(database: db)

        let stage = Stage(title: "Delete Me")
        try repo.upsertStage(stage)

        try repo.deleteStage(id: stage.id)
        let fetched = try repo.fetchStage(id: stage.id)

        XCTAssertNil(fetched)
    }
}
