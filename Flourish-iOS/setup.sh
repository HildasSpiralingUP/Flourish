#!/bin/bash
# Generates the Xcode project from project.yml using xcodegen.
# Run this once before opening in Xcode.

set -e

if ! command -v xcodegen &>/dev/null; then
  echo "→ Installing xcodegen via Homebrew..."
  if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew not found. Install it from https://brew.sh first."
    exit 1
  fi
  brew install xcodegen
fi

echo "→ Generating Xcode project..."
cd "$(dirname "$0")"
xcodegen generate

echo "✅ Done. Open Flourish.xcodeproj in Xcode."
open Flourish.xcodeproj
