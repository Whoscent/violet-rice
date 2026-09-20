#!/usr/bin/env bash
# Automatically handles what to run the ./choose-bg.py script with

# ---- move to project root directory --------------------------------
PROJECT_DIR="$(dirname $(realpath "$0"))"
cd "$PROJECT_DIR"

# ---- detect Python environment -------------------------------------
export PATH=$PATH:$HOME/.local/bin
PYTHON=""

if [ -d ".venv" ]; then
  PYTHON=".venv/bin/python"
elif command -v uv >/dev/null 2>&1; then
  PYTHON="uv run"
else
  PYTHON="python3"
fi

# ---- launch ./choose-bg.py -----------------------------------------
$PYTHON ./choose-bg.py "$@"
