#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web (remote sessions)
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Idempotent: skip everything if both tools are already available
if command -v markitdown >/dev/null 2>&1 && command -v ffmpeg >/dev/null 2>&1; then
  echo "markitdown and ffmpeg already installed, skipping"
  exit 0
fi

if ! command -v markitdown >/dev/null 2>&1; then
  # cffi first: the container's Debian-packaged 'cryptography' lacks _cffi_backend,
  # which breaks markitdown's PDF converter unless a pip-installed cffi is present
  pip install --quiet cffi "markitdown[all]"
fi

# ffmpeg is needed by markitdown's audio transcription converter
if ! command -v ffmpeg >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq || true
  apt-get install -y -qq ffmpeg
fi

echo "session-start: markitdown $(markitdown --version 2>/dev/null || echo '?') and ffmpeg ready"
