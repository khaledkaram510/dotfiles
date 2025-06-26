#!/bin/bash

# Create a backup of settings.json
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE="${SETTINGS_FILE}.$(date +%Y%m%d%H%M%S).bak"

echo "Creating backup of settings.json at ${BACKUP_FILE}"
cp "$SETTINGS_FILE" "$BACKUP_FILE"

# Create a temporary file for the new settings
TEMP_FILE=$(mktemp)

# Generate the updated settings.json with the new WhichKey bindings
cat << 'EOF' > "$TEMP_FILE"
{
  "whichkey.bindings": [
    {
      "key": "c",
      "name": "+Copilot",
      "bindings": [
        {
          "key": "c",
          "name": "Chat",
          "type": "command",
          "command": "github.copilot.chat.toggleCopilotChat"
        },
        {
          "key": "s",
          "name": "Suggest",
          "type": "command",
          "command": "github.copilot.generate"
        },
        {
          "key": "a",
          "name": "Accept suggestion",
          "type": "command",
          "command": "github.copilot.acceptCursorPanelSolution"
        },
        {
          "key": "n",
          "name": "Next suggestion",
          "type": "command",
          "command": "github.copilot.nextPanelSolution"
        },
        {
          "key": "p",
          "name": "Previous suggestion",
          "type": "command",
          "command": "github.copilot.previousPanelSolution"
        },
        {
          "key": "d",
          "name": "Dismiss suggestion",
          "type": "command",
          "command": "github.copilot.dismissCursorSuggestion"
        }
      ]
    },
    {
      "key": "d",
      "name": "+Docker",
      "bindings": [
        {
          "key": "b",
          "name": "Build",
          "type": "command",
          "command": "docker.build"
        },
        {
          "key": "c",
          "name": "Compose Up",
          "type": "command",
          "command": "docker-compose.up"
        },
        {
          "key": "d",
          "name": "Compose Down",
          "type": "command",
          "command": "docker-compose.down"
        },
        {
          "key": "i",
          "name": "Images",
          "type": "command",
          "command": "docker.images.focus"
        },
        {
          "key": "r",
          "name": "Run",
          "type": "command",
          "command": "docker.run"
        },
        {
          "key": "s",
          "name": "Start",
          "type": "command",
          "command": "docker.start"
        },
        {
          "key": "S",
          "name": "Stop",
          "type": "command",
          "command": "docker.stop"
        },
        {
          "key": "v",
          "name": "View Logs",
          "type": "command",
          "command": "docker.logs"
        }
      ]
    },
    {
      "key": "v",
      "name": "+Neovim",
      "bindings": [
        {
          "key": "c",
          "name": "Clear highlights",
          "type": "command",
          "command": "vscode-neovim.send",
          "args": ":nohlsearch<CR>"
        },
        {
          "key": "e",
          "name": "Edit file",
          "type": "command",
          "command": "workbench.action.files.openFile"
        },
        {
          "key": "f",
          "name": "Find file",
          "type": "command",
          "command": "vscode-neovim.send",
          "args": ":VSQuickOpen<CR>"
        },
        {
          "key": "t",
          "name": "+Treesitter",
          "bindings": [
            {
              "key": "s",
              "name": "+Selection",
              "bindings": [
                {
                  "key": "v",
                  "name": "Start Visual Selection",
                  "type": "command",
                  "command": "vscode-neovim.send",
                  "args": ":TSVisualSelection<CR>"
                },
                {
                  "key": "i",
                  "name": "Incremental Selection",
                  "type": "command",
                  "command": "vscode-neovim.send",
                  "args": ":TSIncremental<CR>"
                },
                {
                  "key": "d",
                  "name": "Decremental Selection",
                  "type": "command",
                  "command": "vscode-neovim.send",
                  "args": ":TSDecremental<CR>"
                }
              ]
            },
            {
              "key": "n",
              "name": "Next Function",
              "type": "command",
              "command": "vscode-neovim.send",
              "args": "]f"
            },
            {
              "key": "p",
              "name": "Previous Function",
              "type": "command",
              "command": "vscode-neovim.send",
              "args": "[f"
            }
          ]
        },
        {
          "key": "w",
          "name": "Write buffer",
          "type": "command", 
          "command": "workbench.action.files.save"
        },
        {
          "key": "q",
          "name": "Quit buffer",
          "type": "command",
          "command": "workbench.action.closeActiveEditor"
        }
      ]
    }
  ]
}
EOF

# Create a temporary Python script to merge settings
PYTHON_SCRIPT=$(mktemp)
cat << 'EOF' > "$PYTHON_SCRIPT"
#!/usr/bin/env python3
import json
import sys

# Read the current settings.json
with open(sys.argv[1], 'r') as f:
    settings = json.load(f)

# Read the new whichkey bindings
with open(sys.argv[2], 'r') as f:
    new_bindings = json.load(f)

# Update the settings with the new whichkey bindings
settings["whichkey.bindings"] = new_bindings["whichkey.bindings"]

# Sort the bindings based on key (special chars, lowercase, uppercase, numbers)
def sort_key(item):
    key = item.get("key", "")
    if key and key[0] not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789":
        return "1" + key
    elif key and key[0].islower():
        return "2" + key
    elif key and key[0].isupper():
        return "3" + key
    else:
        return "4" + key

# Sort top-level bindings
settings["whichkey.bindings"] = sorted(settings["whichkey.bindings"], key=sort_key)

# Recursively sort nested bindings
def sort_nested_bindings(bindings):
    if not bindings:
        return bindings
    
    sorted_bindings = sorted(bindings, key=sort_key)
    for binding in sorted_bindings:
        if "bindings" in binding:
            binding["bindings"] = sort_nested_bindings(binding["bindings"])
    
    return sorted_bindings

for binding in settings["whichkey.bindings"]:
    if "bindings" in binding:
        binding["bindings"] = sort_nested_bindings(binding["bindings"])

# Write the updated settings back to a file
with open(sys.argv[3], 'w') as f:
    json.dump(settings, f, indent=2)
EOF

# Make the Python script executable
chmod +x "$PYTHON_SCRIPT"

# Create a temporary file for the merged settings
MERGED_FILE=$(mktemp)

# Run the Python script to merge the settings
echo "Merging WhichKey bindings..."
python3 "$PYTHON_SCRIPT" "$SETTINGS_FILE" "$TEMP_FILE" "$MERGED_FILE"

# Check if Python script succeeded
if [ $? -eq 0 ]; then
    # Replace the original file with the merged version
    mv "$MERGED_FILE" "$SETTINGS_FILE"
    echo "Successfully updated WhichKey bindings with:"
    echo "- New Neovim section with leader key bindings"
    echo "- New Copilot section"
    echo "- New Docker section"
    echo "- All bindings sorted according to pattern: special characters first, lowercase a-z, uppercase A-Z, numbers"
    echo "Original file backed up at: $BACKUP_FILE"
else
    rm "$MERGED_FILE"
    echo "Error: Failed to update settings.json"
    echo "Please check the file manually"
    echo "Original file is unchanged."
fi

# Cleanup temporary files
rm "$TEMP_FILE"
rm "$PYTHON_SCRIPT"

# Update keybindings for Neovim commands
KEYBINDINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/keybindings.json"
KEYBINDINGS_BACKUP="${KEYBINDINGS_FILE}.$(date +%Y%m%d%H%M%S).bak"

echo "Creating backup of keybindings.json at ${KEYBINDINGS_BACKUP}"
cp "$KEYBINDINGS_FILE" "$KEYBINDINGS_BACKUP"

# Create a temporary file for the new keybindings
TEMP_KB_FILE=$(mktemp)

# Create a Python script to update the keybindings
KB_PYTHON_SCRIPT=$(mktemp)
cat << 'EOF' > "$KB_PYTHON_SCRIPT"
#!/usr/bin/env python3
import json
import sys

# Read the current keybindings.json
with open(sys.argv[1], 'r') as f:
    keybindings = json.load(f)

# Filter out any existing Neovim leader keybindings
filtered_keybindings = [kb for kb in keybindings if not kb.get("key", "").startswith("space v")]

# New Neovim leader keybindings to add
new_keybindings = [
    {
        "key": "space v c",
        "command": "vscode-neovim.send",
        "args": ":nohlsearch<CR>",
        "when": "neovim.mode == normal && !inputFocus && !whichkeyActive"
    },
    {
        "key": "space v f",
        "command": "vscode-neovim.send",
        "args": ":VSQuickOpen<CR>",
        "when": "neovim.mode == normal && !inputFocus && !whichkeyActive"
    },
    {
        "key": "space v w",
        "command": "vscode-neovim.send",
        "args": ":w<CR>",
        "when": "neovim.mode == normal && !inputFocus && !whichkeyActive"
    },
    {
        "key": "space v q",
        "command": "vscode-neovim.send",
        "args": ":q<CR>",
        "when": "neovim.mode == normal && !inputFocus && !whichkeyActive"
    },
    {
        "key": "space v t s i",
        "command": "vscode-neovim.send",
        "args": ":TSIncremental<CR>",
        "when": "neovim.mode == normal && !inputFocus && !whichkeyActive"
    },
    {
        "key": "space v t s d",
        "command": "vscode-neovim.send",
        "args": ":TSDecremental<CR>",
        "when": "neovim.mode == normal && !inputFocus && !whichkeyActive"
    },
    {
        "key": "space v t s v",
        "command": "vscode-neovim.send",
        "args": ":TSVisualSelection<CR>",
        "when": "neovim.mode == normal && !inputFocus && !whichkeyActive"
    }
]

# Combine filtered keybindings with new ones
updated_keybindings = filtered_keybindings + new_keybindings

# Write the updated keybindings back to a file
with open(sys.argv[2], 'w') as f:
    json.dump(updated_keybindings, f, indent=2)
EOF

# Make the Python script executable
chmod +x "$KB_PYTHON_SCRIPT"

# Run the Python script to update the keybindings
echo "Updating keybindings..."
python3 "$KB_PYTHON_SCRIPT" "$KEYBINDINGS_FILE" "$TEMP_KB_FILE"

# Check if Python script succeeded
if [ $? -eq 0 ]; then
    # Replace the original file with the updated version
    mv "$TEMP_KB_FILE" "$KEYBINDINGS_FILE"
    echo "Successfully updated keybindings.json with Neovim leader key bindings"
    echo "Original file backed up at: $KEYBINDINGS_BACKUP"
else
    rm "$TEMP_KB_FILE"
    echo "Error: Failed to update keybindings.json"
    echo "Please check the file manually"
    echo "Original file is unchanged."
fi

# Cleanup temporary files
rm "$KB_PYTHON_SCRIPT"

echo "All tasks completed successfully."
