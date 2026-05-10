#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${APP_DIR}"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Installing with Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required. Install Homebrew first: https://brew.sh"
    exit 1
  fi
  brew install xcodegen
fi

echo "Generating Xcode project from project.yml..."
xcodegen generate

echo "Opening StageDesignerApp.xcodeproj..."
open StageDesignerApp.xcodeproj

echo "Done. In Xcode, choose an iPhone simulator and press Run."
