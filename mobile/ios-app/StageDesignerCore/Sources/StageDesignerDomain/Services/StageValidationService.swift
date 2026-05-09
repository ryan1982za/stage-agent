import Foundation

public enum StageValidationError: Error, Equatable {
    case emptyTitle
    case invalidElementDimension(elementId: UUID)
    case negativeZIndex(elementId: UUID)
    case duplicateZIndex
}

public struct StageValidationService {
    public init() {}

    public func validate(_ stage: Stage) throws {
        if stage.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw StageValidationError.emptyTitle
        }

        var zIndexes = Set<Int>()

        for element in stage.elements {
            if element.width <= 0 || element.height <= 0 {
                throw StageValidationError.invalidElementDimension(elementId: element.id)
            }

            if element.zIndex < 0 {
                throw StageValidationError.negativeZIndex(elementId: element.id)
            }

            if zIndexes.contains(element.zIndex) {
                throw StageValidationError.duplicateZIndex
            }
            zIndexes.insert(element.zIndex)
        }
    }
}
