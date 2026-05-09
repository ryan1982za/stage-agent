import Foundation

public struct StageExportFilesResult {
    public let jsonURL: URL
    public let csvURL: URL

    public init(jsonURL: URL, csvURL: URL) {
        self.jsonURL = jsonURL
        self.csvURL = csvURL
    }
}

public final class WriteStageExportFilesUseCase {
    private let exportStageUseCase: ExportStageUseCase

    public init(exportStageUseCase: ExportStageUseCase) {
        self.exportStageUseCase = exportStageUseCase
    }

    public func execute(stageId: UUID, outputDirectory: URL, baseFileName: String) throws -> StageExportFilesResult {
        let export = try exportStageUseCase.execute(stageId: stageId)

        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let jsonURL = outputDirectory.appendingPathComponent("\(baseFileName).json")
        let csvURL = outputDirectory.appendingPathComponent("\(baseFileName).csv")

        try export.json.write(to: jsonURL, atomically: true, encoding: .utf8)
        try export.csv.write(to: csvURL, atomically: true, encoding: .utf8)

        return StageExportFilesResult(jsonURL: jsonURL, csvURL: csvURL)
    }
}
