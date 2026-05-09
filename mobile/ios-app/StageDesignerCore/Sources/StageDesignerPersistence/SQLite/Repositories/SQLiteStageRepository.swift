import Foundation
import SQLite3
import StageDesignerDomain

public final class SQLiteStageRepository: StageRepository {
    private let database: SQLiteDatabase

    public init(database: SQLiteDatabase) {
        self.database = database
    }

    public func fetchAllStages() throws -> [Stage] {
        let sql = "SELECT id, title, discipline_label, location, notes, updated_at FROM stage ORDER BY updated_at DESC;"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        var stages: [Stage] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            let idText = stringValue(statement, index: 0)
            let title = stringValue(statement, index: 1)
            let discipline = stringValue(statement, index: 2)
            let location = stringValue(statement, index: 3)
            let notes = stringValue(statement, index: 4)
            let updatedAtText = stringValue(statement, index: 5)

            guard let id = UUID(uuidString: idText) else {
                continue
            }

            let stage = Stage(
                id: id,
                title: title,
                disciplineLabel: discipline,
                location: location,
                notes: notes,
                updatedAt: database.parse(dateString: updatedAtText),
                elements: [],
                checklist: [],
                runNotes: []
            )
            stages.append(stage)
        }

        return stages
    }

    public func fetchStage(id: UUID) throws -> Stage? {
        let sql = "SELECT id, title, discipline_label, location, notes, updated_at FROM stage WHERE id = ? LIMIT 1;"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: id.uuidString.lowercased())

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return nil
        }

        let idText = stringValue(statement, index: 0)
        let title = stringValue(statement, index: 1)
        let discipline = stringValue(statement, index: 2)
        let location = stringValue(statement, index: 3)
        let notes = stringValue(statement, index: 4)
        let updatedAtText = stringValue(statement, index: 5)

        guard let rowId = UUID(uuidString: idText) else {
            return nil
        }

        return Stage(
            id: rowId,
            title: title,
            disciplineLabel: discipline,
            location: location,
            notes: notes,
            updatedAt: database.parse(dateString: updatedAtText),
            elements: [],
            checklist: [],
            runNotes: []
        )
    }

    public func upsertStage(_ stage: Stage) throws {
        let sql = """
        INSERT INTO stage (id, title, discipline_label, location, notes, updated_at)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            title = excluded.title,
            discipline_label = excluded.discipline_label,
            location = excluded.location,
            notes = excluded.notes,
            updated_at = excluded.updated_at;
        """

        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: stage.id.uuidString.lowercased())
        bindText(statement, index: 2, value: stage.title)
        bindText(statement, index: 3, value: stage.disciplineLabel)
        bindText(statement, index: 4, value: stage.location)
        bindText(statement, index: 5, value: stage.notes)
        bindText(statement, index: 6, value: database.format(date: stage.updatedAt))

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteDatabaseError.stepFailed(message: database.lastErrorMessage())
        }
    }

    public func deleteStage(id: UUID) throws {
        let sql = "DELETE FROM stage WHERE id = ?;"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: id.uuidString.lowercased())

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteDatabaseError.stepFailed(message: database.lastErrorMessage())
        }
    }

    private func stringValue(_ statement: OpaquePointer?, index: Int32) -> String {
        guard let raw = sqlite3_column_text(statement, index) else {
            return ""
        }
        return String(cString: raw)
    }

    private func bindText(_ statement: OpaquePointer?, index: Int32, value: String) {
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_text(statement, index, value, -1, transient)
    }
}
