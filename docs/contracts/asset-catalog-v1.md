# Asset Catalog v1 Baseline

This catalog defines the minimum set of stage setup assets required for v1.

## Categories

- Target
- Prop
- Boundary
- Marker

## Built-in Assets

| Asset ID | Name | Category | Default Width | Default Height | Notes |
|---|---|---|---:|---:|---|
| target-paper-standard | Paper Target | Target | 0.46 | 0.76 | Generic silhouette target |
| target-steel-round | Steel Round Plate | Target | 0.30 | 0.30 | Circular steel plate |
| target-mini-paper | Mini Paper Target | Target | 0.23 | 0.38 | Reduced-size paper target |
| target-no-shoot | No-Shoot Target | Target | 0.46 | 0.76 | Penalty/no-shoot representation |
| prop-barrel-standard | Barrel | Prop | 0.60 | 0.90 | Standard barrel obstacle |
| prop-wall-section | Wall Section | Prop | 1.20 | 0.10 | Linear wall segment |
| boundary-fault-line | Fault Line | Boundary | 1.00 | 0.05 | Shooter position boundary |
| boundary-box-marker | Box Marker | Boundary | 0.70 | 0.70 | Shooting box area marker |
| marker-start-point | Start Point | Marker | 0.30 | 0.30 | Start marker |
| marker-safety-zone | Safety Marker | Marker | 0.80 | 0.80 | Safety reference area |
| prop-cone | Cone | Prop | 0.30 | 0.45 | Physical placement marker |

## Custom Asset Rules

- User custom assets must provide: name, category, default width, default height.
- Custom asset names must be unique per local device catalog.
- Custom assets cannot overwrite built-in catalog entries.

## Catalog Constraints

- Width and height must be positive decimal values.
- Category must map to one of the v1 categories.
- Asset metadata is local-only in v1.
