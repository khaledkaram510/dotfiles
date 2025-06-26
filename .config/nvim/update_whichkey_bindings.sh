#!/bin/bash

# Create a backup of settings.json
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE="${SETTINGS_FILE}.$(date +%Y%m%d%H%M%S).bak"

echo "Creating backup of settings.json at ${BACKUP_FILE}"
cp "$SETTINGS_FILE" "$BACKUP_FILE"

# Create a temporary file for the new settings
TEMP_FILE=$(mktemp)

# Write the jq script to a separate file
JQ_SCRIPT=$(mktemp)
cat << 'EOF' > "$JQ_SCRIPT"
# First, define a function to sort bindings by key according to our pattern
def sort_key:
  . as $item |
  if $item.key | test("^[^a-zA-Z0-9]") then
    "1" + $item.key                    # Special characters first
  elif $item.key | test("^[a-z]") then
    "2" + $item.key                    # Lowercase letters second
  elif $item.key | test("^[A-Z]") then
    "3" + $item.key                    # Uppercase letters third
  else
    "4" + $item.key                    # Numbers last
  end;

# Process bindings recursively, sorting at each level
def process_bindings:
  sort_by(sort_key) |
  map(
    if .bindings then
      . + {bindings: (.bindings | process_bindings)}
    else
      .
    end
  );

# Get current whichkey bindings or create empty array if it doesn't exist
. as $root |
if $root | has("whichkey.bindings") then
  .
else
  . + {"whichkey.bindings": []}
end |

# Update whichkey.bindings with new sections
.["whichkey.bindings"] = 
  # First, remove any existing Copilot, Docker, or Neovim Commands sections
  (.["whichkey.bindings"] | 
    map(select(.name != "+Copilot" and .name != "+Docker" and .name != "+Neovim")) |
    
    # Add new sections
    . + [
      # Copilot section
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
      
      # Docker section
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
      
      # Neovim Commands section
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
  ) |
  # Process the bindings to sort everything
  process_bindings
EOF

# Run jq with the script file
jq -f "$JQ_SCRIPT" "$SETTINGS_FILE" > "$TEMP_FILE"

# Check if jq succeeded
if [ $? -eq 0 ]; then
  # Replace the original file with the updated version
  mv "$TEMP_FILE" "$SETTINGS_FILE"
  echo "Successfully updated WhichKey bindings with:"
  echo "- New Neovim section with leader key bindings"
  echo "- New Copilot section"
  echo "- New Docker section"
  echo "- All bindings sorted according to pattern: special characters first, lowercase a-z, uppercase A-Z, numbers"
  echo "Original file backed up at: $BACKUP_FILE"
else
  rm "$TEMP_FILE"
  echo "Error: Failed to update settings.json"
  echo "Please check the file manually"
  echo "Original file is unchanged."
fi

# Cleanup the jq script file
rm "$JQ_SCRIPT"

# Update keybindings for Neovim commands
KEYBINDINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/keybindings.json"
KEYBINDINGS_BACKUP="${KEYBINDINGS_FILE}.$(date +%Y%m%d%H%M%S).bak"

echo "Creating backup of keybindings.json at ${KEYBINDINGS_BACKUP}"
cp "$KEYBINDINGS_FILE" "$KEYBINDINGS_BACKUP"

# Create a temporary file for the new keybindings
TEMP_FILE=$(mktemp)
JQ_SCRIPT_KB=$(mktemp)

# Write jq script for keybindings to a file
cat << 'EOF' > "$JQ_SCRIPT_KB"
# Remove any existing Neovim leader key mappings (to avoid conflicts)
map(select(.key | startswith("space v") | not)) +

# Add new Neovim leader key mappings in keybindings.json
[
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
EOF

# Run jq with the keybindings script
jq -f "$JQ_SCRIPT_KB" "$KEYBINDINGS_FILE" > "$TEMP_FILE"

# Check if jq succeeded for keybindings
if [ $? -eq 0 ]; then
  # Replace the original file with the updated version
  mv "$TEMP_FILE" "$KEYBINDINGS_FILE"
  echo "Successfully updated keybindings.json with Neovim leader key bindings"
  echo "Original file backed up at: $KEYBINDINGS_BACKUP"
else
  rm "$TEMP_FILE"
  echo "Error: Failed to update keybindings.json"
  echo "Please check the file manually"
  echo "Original file is unchanged."
fi

# Cleanup the jq script for keybindings
rm "$JQ_SCRIPT_KB"
