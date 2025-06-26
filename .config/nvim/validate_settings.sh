#!/bin/zsh

# This script validates and fixes common JSON issues in settings.json
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json.bak"

# Create a backup if it doesn't exist
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "Created backup of settings.json"
fi

# Create a temporary file
TEMP_FILE=$(mktemp)

# First, try to normalize the file encoding and line endings
echo "Normalizing file encoding and line endings..."
cat "$SETTINGS_FILE" | tr -cd '\11\12\15\40-\176' | iconv -f utf-8 -t utf-8 | dos2unix > "$TEMP_FILE"
mv "$TEMP_FILE" "$SETTINGS_FILE"

# Now use Python to fix and validate the JSON
echo "Fixing and validating JSON structure..."
python3 - "$SETTINGS_FILE" "$TEMP_FILE" << 'EOF'
import json
import sys
import re
import codecs

def strip_comments(text):
    # First, handle multi-line comments
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    # Then handle single line comments
    lines = []
    for line in text.splitlines():
        # Remove inline comments
        if '//' in line:
            line = line[:line.index('//')]
        if line.strip():
            lines.append(line)
    return '\n'.join(lines)

def fix_json(content):
    # Remove any BOM
    if content.startswith(codecs.BOM_UTF8.decode('utf-8')):
        content = content[1:]
    
    # Remove control characters
    content = ''.join(ch for ch in content if ch >= ' ' or ch in ['\n', '\r', '\t'])
    
    # Remove comments
    content = strip_comments(content)
    
    # Fix unquoted property names
    content = re.sub(r'([{,]\s*)(\w+)(\s*:)', r'\1"\2"\3', content)
    
    # Fix trailing commas
    content = re.sub(r',(\s*[}\]])', r'\1', content)
    
    # Escape backslashes in strings
    def escape_strings(match):
        return match.group(1) + json.dumps(match.group(2))[1:-1] + match.group(3)
    content = re.sub(r'(:\s*")(.*?)("(?=\s*[,}]))', escape_strings, content)
    
    return content.strip()

try:
    with open(sys.argv[1], 'r', encoding='utf-8-sig') as f:
        content = f.read()
    
    # First try to load as-is
    try:
        data = json.loads(content)
    except json.JSONDecodeError:
        # If that fails, try fixing common issues
        fixed_content = fix_json(content)
        data = json.loads(fixed_content)
    
    # Write the validated JSON
    with open(sys.argv[2], 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
    print("Successfully fixed and validated JSON")
    
except json.JSONDecodeError as e:
    print(f"JSON Error: {str(e)}")
    print(f"Line {e.lineno}, Column {e.colno}")
    print("Context:")
    lines = content.split('\n')
    start = max(0, e.lineno - 3)
    end = min(len(lines), e.lineno + 2)
    for i in range(start, end):
        if i == e.lineno - 1:
            print(f">>> {lines[i]}")
        else:
            print(f"    {lines[i]}")
    sys.exit(1)
except Exception as e:
    print(f"Error: {str(e)}")
    sys.exit(1)
EOF

if [ $? -eq 0 ]; then
    # Format the JSON using jq for consistent style
    if jq '.' "$TEMP_FILE" > "$SETTINGS_FILE"; then
        echo "Successfully fixed and formatted settings.json"
        echo "Original file backed up at: $BACKUP_FILE"
        # Now we can run the VSpaceCode fix script
        echo "Running VSpaceCode fix script..."
        ./fix_vspacecode_settings.sh
    else
        echo "Error: Failed to format the fixed JSON"
        mv "$TEMP_FILE" "$SETTINGS_FILE"
    fi
fi

rm -f "$TEMP_FILE"
