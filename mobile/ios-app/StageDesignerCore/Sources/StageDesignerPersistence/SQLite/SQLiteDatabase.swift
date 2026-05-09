import Foundation
import SQLite3

public enum SQLiteDatabaseError: Error {
    case openFailed(path: String)
    case executeFailed(message: String)
    case prepareFailed(message: String)
    case stepFailed(message: String)
}

public final class SQLiteDatabase {
    private var handle: OpaquePointer?
    private let dateFormatter: ISO8601DateFormatter

    public init(path: String) throws {
        var db: OpaquePointer?
        if sqlite3_open(path, &db) != SQLITE_OK {
            throw SQLiteDatabaseError.openFailed(path: path)
        }

        self.handle = db

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.dateFormatter = formatter
    }

    deinit {
        if let handle {
            sqlite3_close(handle)
        }
    }

    public func execute(sql: String) throws {
        guard let handle else { return }

        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(handle, sql, nil, nil, &errorMessage) != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Unknown SQLite execute error"
            sqlite3_free(errorMessage)
            throw SQLiteDatabaseError.executeFailed(message: message)
        }
    }

    public func beginTransaction() throws {
        try execute(sql: "BEGIN TRANSACTION;")
    }

    public func commit() throws {
        try execute(sql: "COMMIT;")
    }

    public func rollback() throws {
        try execute(sql: "ROLLBACK;")
    }

    func prepare(_ sql: String) throws -> OpaquePointer? {
        guard let handle else { return nil }

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(handle, sql, -1, &statement, nil) != SQLITE_OK {
            throw SQLiteDatabaseError.prepareFailed(message: lastErrorMessage())
        }
        return statement
    }

    func lastErrorMessage() -> String {
        guard let handle, let cString = sqlite3_errmsg(handle) else {
            return "Unknown SQLite error"
        }
        return String(cString: cString)
    }

    public func format(date: Date) -> String {
        dateFormatter.string(from: date)
    }

    public func parse(dateString: String) -> Date {
        dateFormatter.date(from: dateString) ?? Date()
    }
}
