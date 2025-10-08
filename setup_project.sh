#!/usr/bin/env bash
set -e

# Activate virtual environment
if [[ -d "venv" ]]; then
  source venv/bin/activate
  echo "✅ Virtual environment activated."
else
  echo "❌ No venv directory found."
  exit 1
fi

# Load .env safely (works on Ubuntu + macOS)
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
  echo "✅ Environment variables loaded from .env"
fi

# Set alias for convenience
hound() {
  ./hound.py "$@"
}

echo "✅ Alias 'hound' set for this session."

# Prompts
read -rp "Enter project name: " project_name

# Folder autocomplete for source path
read -e -p "Enter project folder path: " source_path
while [[ ! -d "$source_path" ]]; do
  echo "❌ '$source_path' is not a valid directory."
  read -e -p "Enter project folder path: " source_path
done

hound project create "$project_name" "$source_path"
echo "✅ Project $project_name created."

# Find README.md
readme_path="${source_path%/}/README.md"
if [[ ! -f "$readme_path" ]]; then
  echo "❌ README.md not found in $source_path"
  exit 1
fi

# Parse audit scope locally
echo "📖 Parsing audit scope from README.md..."
audit_scope_line=$(python3 parse_audit_scope.py "$readme_path" "$project_name")
eval "$audit_scope_line"
echo "✅ Audit scope extracted and saved to ${project_name}-scope.txt"

# Display scope and confirm with user
echo
echo "------------------------------"
echo "📋  Extracted Audit Scope:"
echo "$audit_scope" | tr ',' '\n' | sed 's/^/  • /'
echo "------------------------------"
echo

read -rp "Do you agree with this audit scope and want to continue with graph generation? (y/n): " confirm
case "$confirm" in
  [yY][eE][sS]|[yY])
    echo "✅ Continuing with graph generation..."
    hound graph build "$project_name" --auto --files "$audit_scope"
    ;;
  *)
    echo "❌ Aborted by user. No graph generated."
    exit 0
    ;;
esac
