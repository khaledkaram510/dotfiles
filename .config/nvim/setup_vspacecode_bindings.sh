#!/bin/zsh

# This script sets up the WhichKey bindings for VSpaceCode functionality
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json.bak"

# Create a backup if it doesn't exist
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "Created backup of settings.json"
fi

# Create a temporary file
TEMP_FILE=$(mktemp)

# Add WhichKey bindings using jq
jq '
  .["whichkey.bindings"] = [
    {
      "key": "f",
      "name": "File",
      "type": "bindings",
      "bindings": [
        {
          "key": "f",
          "name": "Open File",
          "type": "command",
          "command": "workbench.action.files.openFile"
        },
        {
          "key": "s",
          "name": "Save",
          "type": "command",
          "command": "workbench.action.files.save"
        },
        {
          "key": "S",
          "name": "Save All",
          "type": "command",
          "command": "workbench.action.files.saveAll"
        },
        {
          "key": "n",
          "name": "New File",
          "type": "command",
          "command": "workbench.action.files.newUntitledFile"
        }
      ]
    },
    {
      "key": "e",
      "name": "Edit",
      "type": "bindings",
      "bindings": [
        {
          "key": "u",
          "name": "Undo",
          "type": "command",
          "command": "undo"
        },
        {
          "key": "r",
          "name": "Redo",
          "type": "command",
          "command": "redo"
        }
      ]
    },
    {
      "key": "b",
      "name": "Buffer",
      "type": "bindings",
      "bindings": [
        {
          "key": "b",
          "name": "Show All Buffers",
          "type": "command",
          "command": "workbench.action.showAllEditorsByMostRecentlyUsed"
        },
        {
          "key": "d",
          "name": "Close Current",
          "type": "command",
          "command": "workbench.action.closeActiveEditor"
        },
        {
          "key": "n",
          "name": "Next Buffer",
          "type": "command",
          "command": "workbench.action.nextEditor"
        },
        {
          "key": "p",
          "name": "Previous Buffer",
          "type": "command",
          "command": "workbench.action.previousEditor"
        }
      ]
    },
    {
      "key": "s",
      "name": "Search",
      "type": "bindings",
      "bindings": [
        {
          "key": "s",
          "name": "Search in File",
          "type": "command",
          "command": "actions.find"
        },
        {
          "key": "g",
          "name": "Search in Project",
          "type": "command",
          "command": "workbench.action.findInFiles"
        }
      ]
    },
    {
      "key": "g",
      "name": "Git",
      "type": "bindings",
      "bindings": [
        {
          "key": "s",
          "name": "Status",
          "type": "command",
          "command": "workbench.view.scm"
        },
        {
          "key": "p",
          "name": "Pull",
          "type": "command",
          "command": "git.pull"
        },
        {
          "key": "P",
          "name": "Push",
          "type": "command",
          "command": "git.push"
        },
        {
          "key": "c",
          "name": "Commit",
          "type": "command",
          "command": "git.commit"
        }
      ]
    },
    {
      "key": "w",
      "name": "Window",
      "type": "bindings",
      "bindings": [
        {
          "key": "s",
          "name": "Split Horizontal",
          "type": "command",
          "command": "workbench.action.splitEditorDown"
        },
        {
          "key": "v",
          "name": "Split Vertical",
          "type": "command",
          "command": "workbench.action.splitEditorRight"
        },
        {
          "key": "h",
          "name": "Focus Left",
          "type": "command",
          "command": "workbench.action.focusLeftGroup"
        },
        {
          "key": "j",
          "name": "Focus Down",
          "type": "command",
          "command": "workbench.action.focusBelowGroup"
        },
        {
          "key": "k",
          "name": "Focus Up",
          "type": "command",
          "command": "workbench.action.focusAboveGroup"
        },
        {
          "key": "l",
          "name": "Focus Right",
          "type": "command",
          "command": "workbench.action.focusRightGroup"
        }
      ]
    },
    {
      "key": "t",
      "name": "Toggle",
      "type": "bindings",
      "bindings": [
        {
          "key": "s",
          "name": "Sidebar",
          "type": "command",
          "command": "workbench.action.toggleSidebarVisibility"
        },
        {
          "key": "t",
          "name": "Terminal",
          "type": "command",
          "command": "workbench.action.terminal.toggleTerminal"
        },
        {
          "key": "p",
          "name": "Problems",
          "type": "command",
          "command": "workbench.actions.view.problems"
        }
      ]
    },
    {
      "key": "n",
      "name": "Neovim Commands",
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
    },
    {
      "key": "ts",
      "name": "+Treesitter",
      "icon": "symbol-class",
      "type": "bindings",
      "bindings": [
        {
          "key": "v",
          "name": "Visual Selection",
          "type": "command",
          "command": "vscode-neovim.send",
          "args": ":TSVisualSelection<CR>"
        },
        {
          "key": "i",
          "name": "Increment Selection", 
          "type": "command",
          "command": "vscode-neovim.send",
          "args": ":TSIncremental<CR>"
        },
        {
          "key": "d",
          "name": "Decrement Selection",
          "type": "command",
          "command": "vscode-neovim.send",
          "args": ":TSDecremental<CR>" 
        },
        {
          "key": "s",
          "name": "Scope Selection",
          "type": "command",
          "command": "vscode-neovim.send",
          "args": ":TSScopeIncremental<CR>"
        }
      ]
    }
  ] |
  .["whichkey.sortOrder"] = "alphabetically" |
  .["whichkey.delay"] = 200 |
  .["whichkey.showIconsInWIndow"] = true |
  .["vspacecode.bindingOverrides"] = []
' "$SETTINGS_FILE" > "$TEMP_FILE"

# Check if jq succeeded
if [ $? -eq 0 ]; then
    # Replace the original file with the updated version
    mv "$TEMP_FILE" "$SETTINGS_FILE"
    echo "Successfully added WhichKey bindings to settings.json"
    echo ""
    echo "Original file backed up at: $BACKUP_FILE"
else
    rm "$TEMP_FILE"
    echo "Error: Failed to update settings.json"
    echo "Please check the file manually"
fi
