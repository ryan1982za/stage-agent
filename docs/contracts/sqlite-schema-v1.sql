-- SQLite schema baseline for Shooting Stage Designer iOS v1

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS stage (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  discipline_label TEXT NOT NULL DEFAULT '',
  location TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS asset_definition (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  is_custom INTEGER NOT NULL CHECK (is_custom IN (0, 1)),
  default_width REAL NOT NULL CHECK (default_width > 0),
  default_height REAL NOT NULL CHECK (default_height > 0),
  notes TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS stage_element (
  id TEXT PRIMARY KEY,
  stage_id TEXT NOT NULL,
  asset_id TEXT NOT NULL,
  x REAL NOT NULL,
  y REAL NOT NULL,
  width REAL NOT NULL CHECK (width > 0),
  height REAL NOT NULL CHECK (height > 0),
  rotation_deg REAL NOT NULL DEFAULT 0,
  z_index INTEGER NOT NULL CHECK (z_index >= 0),
  FOREIGN KEY (stage_id) REFERENCES stage(id) ON DELETE CASCADE,
  FOREIGN KEY (asset_id) REFERENCES asset_definition(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS checklist_item (
  id TEXT PRIMARY KEY,
  stage_id TEXT NOT NULL,
  text TEXT NOT NULL,
  is_done INTEGER NOT NULL CHECK (is_done IN (0, 1)),
  updated_at TEXT NOT NULL,
  FOREIGN KEY (stage_id) REFERENCES stage(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS run_note (
  id TEXT PRIMARY KEY,
  stage_id TEXT NOT NULL,
  text TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (stage_id) REFERENCES stage(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_stage_element_stage ON stage_element(stage_id);
CREATE INDEX IF NOT EXISTS idx_stage_element_asset ON stage_element(asset_id);
CREATE INDEX IF NOT EXISTS idx_checklist_stage ON checklist_item(stage_id);
CREATE INDEX IF NOT EXISTS idx_run_note_stage ON run_note(stage_id);
