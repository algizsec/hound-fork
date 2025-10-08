#!/usr/bin/env bash
set -e

#Copy config.yaml if not present
if [[ ! -f config.yaml && -f config.yaml.example ]]; then
  cp config.yaml.example config.yaml
  echo "✅ config.yaml created from config.yaml.example."
fi

# Activate venv
if [[ -d "venv" ]]; then
  source venv/bin/activate
  echo "✅ Virtual environment activated."
else
  echo "❌ No venv directory found."
  exit 1
fi

# Load environment variables (safe for Ubuntu/macOS)
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
  echo "✅ Environment variables loaded from .env"
fi

# Set alias
alias hound="./hound.py"
echo "✅ Alias 'hound' set for this session."

# Prompts
read -rp "Enter project name: " project_name
read -rp "Enter source path (e.g. src/app.py): " source_path

hound project create "$project_name" "$source_path"
echo "✅ Project $project_name created"

read -rp "Enter a comma-separated list of audit scope files (starting with ./): " audit_scope

echo "Beginning graph generation..."
hound graph build "$project_name" --auto --files "$audit_scope"