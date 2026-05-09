import Foundation

public enum SQLiteBootstrapError: Error {
    case schemaFileMissing
    case failedToLoadSchema
}

public struct SQLiteBootstrap {
    public let schemaSQL: String

    public init(schemaSQL: String) {
        self.schemaSQL = schemaSQL
    }

    public static func fromFile(at path: String) throws -> SQLiteBootstrap {
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else {
            throw SQLiteBootstrapError.schemaFileMissing
        }

        guard let sql = try? String(contentsOfFile: path, encoding: .utf8) else {
            throw SQLiteBootstrapError.failedToLoadSchema
        }

        return SQLiteBootstrap(schemaSQL: sql)
    }

    // Placeholder to keep app-layer integration unblocked while SQLite engine adapter is implemented.
    public func migrationStatements() -> [String] {
        schemaSQL
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { "\($0);" }
    }
}
