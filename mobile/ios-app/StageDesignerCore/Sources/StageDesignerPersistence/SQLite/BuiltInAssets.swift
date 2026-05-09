import Foundation
import StageDesignerDomain

public enum BuiltInAssets {
    public static let v1Catalog: [AssetDefinition] = [
        AssetDefinition(name: "Paper Target", category: "Target", isCustom: false, defaultWidth: 0.46, defaultHeight: 0.76),
        AssetDefinition(name: "Steel Round Plate", category: "Target", isCustom: false, defaultWidth: 0.30, defaultHeight: 0.30),
        AssetDefinition(name: "Mini Paper Target", category: "Target", isCustom: false, defaultWidth: 0.23, defaultHeight: 0.38),
        AssetDefinition(name: "No-Shoot Target", category: "Target", isCustom: false, defaultWidth: 0.46, defaultHeight: 0.76),
        AssetDefinition(name: "Barrel", category: "Prop", isCustom: false, defaultWidth: 0.60, defaultHeight: 0.90),
        AssetDefinition(name: "Wall Section", category: "Prop", isCustom: false, defaultWidth: 1.20, defaultHeight: 0.10),
        AssetDefinition(name: "Fault Line", category: "Boundary", isCustom: false, defaultWidth: 1.00, defaultHeight: 0.05),
        AssetDefinition(name: "Box Marker", category: "Boundary", isCustom: false, defaultWidth: 0.70, defaultHeight: 0.70),
        AssetDefinition(name: "Start Point", category: "Marker", isCustom: false, defaultWidth: 0.30, defaultHeight: 0.30),
        AssetDefinition(name: "Safety Marker", category: "Marker", isCustom: false, defaultWidth: 0.80, defaultHeight: 0.80),
        AssetDefinition(name: "Cone", category: "Prop", isCustom: false, defaultWidth: 0.30, defaultHeight: 0.45)
    ]
}
