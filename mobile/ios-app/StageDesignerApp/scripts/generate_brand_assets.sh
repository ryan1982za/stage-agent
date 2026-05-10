#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ASSETS_DIR="${APP_DIR}/App/Assets.xcassets"
APPICON_DIR="${ASSETS_DIR}/AppIcon.appiconset"
MARK_DIR="${ASSETS_DIR}/StageAgentMark.imageset"
LOGO_PATH="${1:-${APP_DIR}/../../../docs/Stage Agent.svg}"

if [ ! -f "${LOGO_PATH}" ]; then
  echo "Logo not found: ${LOGO_PATH}"
  echo "Usage: bash ./scripts/generate_brand_assets.sh '/absolute/path/to/Stage Agent.svg'"
  exit 1
fi

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "rsvg-convert not found. Installing librsvg with Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required first. Install from https://brew.sh"
    exit 1
  fi
  brew install librsvg
fi

mkdir -p "${APPICON_DIR}" "${MARK_DIR}"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

MASTER_PNG="${TMP_DIR}/master-1024.png"
rsvg-convert -w 1024 -h 1024 "${LOGO_PATH}" -o "${MASTER_PNG}"

# App icons (iPhone and iPad)
cp "${MASTER_PNG}" "${APPICON_DIR}/app-icon-1024.png"

# iPhone sizes: 40, 60, 58, 87, 80, 120, 180
for size in 40 60 58 87 80 120 180; do
  sips -z "${size}" "${size}" "${MASTER_PNG}" --out "${APPICON_DIR}/app-icon-${size}.png" >/dev/null
done

# iPad sizes: 20, 29, 40, 76, 152
for size in 20 29 40 76 152; do
  sips -z "${size}" "${size}" "${MASTER_PNG}" --out "${APPICON_DIR}/app-icon-ipad-${size}.png" >/dev/null
done

cat > "${APPICON_DIR}/Contents.json" <<'JSON'
{
  "images" : [
    { "filename" : "app-icon-40.png", "idiom" : "iphone", "scale" : "2x", "size" : "20x20" },
    { "filename" : "app-icon-60.png", "idiom" : "iphone", "scale" : "3x", "size" : "20x20" },
    { "filename" : "app-icon-58.png", "idiom" : "iphone", "scale" : "2x", "size" : "29x29" },
    { "filename" : "app-icon-87.png", "idiom" : "iphone", "scale" : "3x", "size" : "29x29" },
    { "filename" : "app-icon-80.png", "idiom" : "iphone", "scale" : "2x", "size" : "40x40" },
    { "filename" : "app-icon-120.png", "idiom" : "iphone", "scale" : "3x", "size" : "40x40" },
    { "filename" : "app-icon-120.png", "idiom" : "iphone", "scale" : "2x", "size" : "60x60" },
    { "filename" : "app-icon-180.png", "idiom" : "iphone", "scale" : "3x", "size" : "60x60" },
    { "filename" : "app-icon-ipad-20.png", "idiom" : "ipad", "scale" : "1x", "size" : "20x20" },
    { "filename" : "app-icon-ipad-40.png", "idiom" : "ipad", "scale" : "2x", "size" : "20x20" },
    { "filename" : "app-icon-ipad-29.png", "idiom" : "ipad", "scale" : "1x", "size" : "29x29" },
    { "filename" : "app-icon-ipad-58.png", "idiom" : "ipad", "scale" : "2x", "size" : "29x29" },
    { "filename" : "app-icon-ipad-40.png", "idiom" : "ipad", "scale" : "1x", "size" : "40x40" },
    { "filename" : "app-icon-ipad-80.png", "idiom" : "ipad", "scale" : "2x", "size" : "40x40" },
    { "filename" : "app-icon-ipad-76.png", "idiom" : "ipad", "scale" : "1x", "size" : "76x76" },
    { "filename" : "app-icon-ipad-152.png", "idiom" : "ipad", "scale" : "2x", "size" : "76x76" },
    { "filename" : "app-icon-1024.png", "idiom" : "ios-marketing", "scale" : "1x", "size" : "1024x1024" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

# In-app mark imageset (square source at 1x/2x/3x)
sips -z 96 96 "${MASTER_PNG}" --out "${MARK_DIR}/stage-agent-mark.png" >/dev/null
sips -z 192 192 "${MASTER_PNG}" --out "${MARK_DIR}/stage-agent-mark@2x.png" >/dev/null
sips -z 288 288 "${MASTER_PNG}" --out "${MARK_DIR}/stage-agent-mark@3x.png" >/dev/null

cat > "${MARK_DIR}/Contents.json" <<'JSON'
{
  "images" : [
    {
      "filename" : "stage-agent-mark.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "stage-agent-mark@2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "stage-agent-mark@3x.png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

echo "Generated app branding assets from: ${LOGO_PATH}"
echo "- ${APPICON_DIR}"
echo "- ${MARK_DIR}"
