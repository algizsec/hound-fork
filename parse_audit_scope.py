#!/usr/bin/env python3
import os, sys, re

if len(sys.argv) < 3:
    print("Usage: parse_audit_scope.py <readme_path> <project_name>")
    sys.exit(1)

readme_path = sys.argv[1]
project_name = sys.argv[2]

# Read README.md
with open(readme_path, "r", encoding="utf-8") as f:
    content = f.read()

# Extract "# Audit scope" section (until next heading or EOF)
match = re.search(r"(?i)#\s*audit\s*scope(.+?)(?:\n#|\Z)", content, re.S)
if not match:
    print("❌ No '# Audit scope' section found in README.md", file=sys.stderr)
    sys.exit(1)

scope_text = match.group(1).strip()

# Extract Solidity/Vyper source paths from markdown list items
# - [name](path/to/file.sol)
paths = re.findall(r'\(([^)]+\.(?:sol|vy))\)', scope_text)
if not paths:
    # Fallback: lines that just list file names
    paths = re.findall(r'[-*]\s+([^\s)]+\.(?:sol|vy))', scope_text)

if not paths:
    print("❌ No Solidity/Vyper paths found under '# Audit scope'.", file=sys.stderr)
    sys.exit(1)

# Normalize and prefix each path with "./"
clean_paths = []
for path in paths:
    path = path.strip()
    if not path.startswith("./"):
        path = "./" + path.lstrip("./")
    clean_paths.append(path)

# Create comma-separated list for shell export
audit_scope = ",".join(clean_paths)

# Write scope file (one file per line)
outfile = f"{project_name}-scope.txt"
with open(outfile, "w", encoding="utf-8") as f:
    for p in clean_paths:
        f.write(p + "\n")

print(f'audit_scope="{audit_scope}"')
