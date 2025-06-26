#!/bin/zsh

# This script fixes common issues in the VSCode settings.json file
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json.bak"

# Create a backup if it doesn't exist
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "Created backup of settings.json"
fi

# Create a temporary file for modifications
TEMP_FILE=$(mktemp)

# Clean up JSON and fix structure using jq
jq '
  def remove_empty:
    # Function to recursively remove empty arrays and objects
    walk(
      if type == "array" then
        select(length > 0)
      elif type == "object" then
        with_entries(select(.value != null and .value != [] and .value != {}))
      else
        .
      end
    );

  # Process vspacecode.bindings
  (.["vspacecode.bindings"] |= (
    map(
      # Keep valid bindings and remove empty ones
      select(. != null and . != {} and (has("bindings") | not or .bindings != []))
    ) |
    # Process the "n" (Neovim Commands) section
    map(
      if .key == "n" and .name == "+Neovim Commands" then
        {
          "key": "n",
          "name": "+Neovim Commands",
          "icon": "vim",
          "type": "bindings",
          "bindings": [
            {
              "key": "f",
              "name": "Quick Open",
              "type": "command",
              "command": "vscode-neovim.send",
              "args": ":VSQuickOpen<CR>"
            },
            {
              "key": "s",
              "name": "+Search",
              "type": "bindings",
              "bindings": [
                {
                  "key": "g",
                  "name": "Search in Files",
                  "type": "command",
                  "command": "vscode-neovim.send",
                  "args": ":VSFindInFiles<CR>"
                }
              ]
            },
            {
              "key": "v",
              "name": "+Visual",
              "type": "bindings",
              "bindings": [
                {
                  "key": "t",
                  "name": "Treesitter Selection",
                  "type": "command",
                  "command": "vscode-neovim.send",
                  "args": ":TSVisualSelection<CR>"
                }
              ]
            },
            {
              "key": "]",
              "name": "Treesitter Increment Selection",
              "type": "command",
              "command": "vscode-neovim.send",
              "args": ":TSIncremental<CR>"
            },
            {
              "key": "[",
              "name": "Treesitter Decrement Selection",
              "type": "command",
              "command": "vscode-neovim.send",
              "args": ":TSDecremental<CR>"
            }
          ]
        }
      else
        .
      end
    )
  )) |
  # Keep non-empty entries in all other bindings arrays
  walk(
    if type == "object" and has("bindings") then
      .bindings |= map(select(. != null and . != {}))
    else
      .
    end
  ) |
  # Apply remove_empty to clean up any remaining empty structures
  remove_empty
' "$SETTINGS_FILE" > "$TEMP_FILE"

# Check if jq succeeded
if [ $? -eq 0 ]; then
    # Replace the original file with the fixed version
    mv "$TEMP_FILE" "$SETTINGS_FILE"
    echo "Successfully fixed settings.json"
    echo "Removed empty bindings"
    echo "Standardized Neovim Commands section"
    echo "Cleaned up JSON structure"
    echo ""
    echo "Original file backed up at: $BACKUP_FILE"
else
    rm "$TEMP_FILE"
    echo "Error: Failed to fix settings.json"
    echo "Please check the file manually"
fi
