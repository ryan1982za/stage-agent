import Foundation

public struct Stage: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var disciplineLabel: String
    public var location: String
    public var notes: String
    public var updatedAt: Date
    public var elements: [StageElement]
    public var checklist: [ChecklistItem]
    public var runNotes: [RunNote]

    public init(
        id: UUID = UUID(),
        title: String,
        disciplineLabel: String = "",
        location: String = "",
        notes: String = "",
        updatedAt: Date = Date(),
        elements: [StageElement] = [],
        checklist: [ChecklistItem] = [],
        runNotes: [RunNote] = []
    ) {
        self.id = id
        self.title = title
        self.disciplineLabel = disciplineLabel
        self.location = location
        self.notes = notes
        self.updatedAt = updatedAt
        self.elements = elements
        self.checklist = checklist
        self.runNotes = runNotes
    }
}

public struct StageElement: Identifiable, Codable, Equatable {
    public let id: UUID
    public let stageId: UUID
    public let assetId: UUID
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    public var rotationDeg: Double
    public var zIndex: Int

    public init(
        id: UUID = UUID(),
        stageId: UUID,
        assetId: UUID,
        x: Double,
        y: Double,
        width: Double,
        height: Double,
        rotationDeg: Double = 0,
        zIndex: Int = 0
    ) {
        self.id = id
        self.stageId = stageId
        self.assetId = assetId
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rotationDeg = rotationDeg
        self.zIndex = zIndex
    }
}

public struct AssetDefinition: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var category: String
    public var isCustom: Bool
    public var defaultWidth: Double
    public var defaultHeight: Double
    public var notes: String

    public init(
        id: UUID = UUID(),
        name: String,
        category: String,
        isCustom: Bool,
        defaultWidth: Double,
        defaultHeight: Double,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.isCustom = isCustom
        self.defaultWidth = defaultWidth
        self.defaultHeight = defaultHeight
        self.notes = notes
    }
}

public struct ChecklistItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public let stageId: UUID
    public var text: String
    public var isDone: Bool
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        stageId: UUID,
        text: String,
        isDone: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.stageId = stageId
        self.text = text
        self.isDone = isDone
        self.updatedAt = updatedAt
    }
}

public struct RunNote: Identifiable, Codable, Equatable {
    public let id: UUID
    public let stageId: UUID
    public var text: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        stageId: UUID,
        text: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.stageId = stageId
        self.text = text
        self.createdAt = createdAt
    }
}
