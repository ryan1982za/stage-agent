import Foundation
import SQLite3
import StageDesignerDomain

public final class SQLiteNotesRepository: NotesRepository {
    private let database: SQLiteDatabase

    public init(database: SQLiteDatabase) {
        self.database = database
    }

    public func fetchChecklist(stageId: UUID) throws -> [ChecklistItem] {
        let sql = "SELECT id, stage_id, text, is_done, updated_at FROM checklist_item WHERE stage_id = ? ORDER BY updated_at DESC;"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: stageId.uuidString.lowercased())

        var result: [ChecklistItem] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            let idText = stringValue(statement, index: 0)
            let stageIdText = stringValue(statement, index: 1)
            let text = stringValue(statement, index: 2)
            let isDone = sqlite3_column_int(statement, 3) == 1
            let updatedAtText = stringValue(statement, index: 4)

            guard
                let id = UUID(uuidString: idText),
                let parsedStageId = UUID(uuidString: stageIdText)
            else {
                continue
            }

            result.append(
                ChecklistItem(
                    id: id,
                    stageId: parsedStageId,
                    text: text,
                    isDone: isDone,
                    updatedAt: database.parse(dateString: updatedAtText)
                )
            )
        }

        return result
    }

    public func fetchRunNotes(stageId: UUID) throws -> [RunNote] {
        let sql = "SELECT id, stage_id, text, created_at FROM run_note WHERE stage_id = ? ORDER BY created_at DESC;"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: stageId.uuidString.lowercased())

        var result: [RunNote] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            let idText = stringValue(statement, index: 0)
            let stageIdText = stringValue(statement, index: 1)
            let text = stringValue(statement, index: 2)
            let createdAtText = stringValue(statement, index: 3)

            guard
                let id = UUID(uuidString: idText),
                let parsedStageId = UUID(uuidString: stageIdText)
            else {
                continue
            }

            result.append(
                RunNote(
                    id: id,
                    stageId: parsedStageId,
                    text: text,
                    createdAt: database.parse(dateString: createdAtText)
                )
            )
        }

        return result
    }

    public func upsertChecklistItem(_ item: ChecklistItem) throws {
        let sql = """
        INSERT INTO checklist_item (id, stage_id, text, is_done, updated_at)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            text = excluded.text,
            is_done = excluded.is_done,
            updated_at = excluded.updated_at;
        """

        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: item.id.uuidString.lowercased())
        bindText(statement, index: 2, value: item.stageId.uuidString.lowercased())
        bindText(statement, index: 3, value: item.text)
        sqlite3_bind_int(statement, 4, item.isDone ? 1 : 0)
        bindText(statement, index: 5, value: database.format(date: item.updatedAt))

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteDatabaseError.stepFailed(message: database.lastErrorMessage())
        }
    }

    public func appendRunNote(_ note: RunNote) throws {
        let sql = "INSERT INTO run_note (id, stage_id, text, created_at) VALUES (?, ?, ?, ?);"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: note.id.uuidString.lowercased())
        bindText(statement, index: 2, value: note.stageId.uuidString.lowercased())
        bindText(statement, index: 3, value: note.text)
        bindText(statement, index: 4, value: database.format(date: note.createdAt))

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
