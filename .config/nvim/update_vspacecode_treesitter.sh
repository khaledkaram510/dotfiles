#!/bin/zsh

# Define the markers for the insertion
FIND_PATTERN='"key": "v",'
INSERTION_CONTENT='{
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
    },'

# Create a temporary file for the modification
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
TEMP_FILE=$(mktemp)

# Insert the content after the pattern
awk -v pattern="$FIND_PATTERN" -v insertion="$INSERTION_CONTENT" '
  {
    print $0
    if ($0 ~ pattern) {
      print "    " insertion
    }
  }
' "$SETTINGS_FILE" > "$TEMP_FILE"

# Apply some cleanup to fix formatting issues that might have occurred
sed -i 's/    {      /    {/g' "$TEMP_FILE"
sed -i 's/    }    ,/    },/g' "$TEMP_FILE"

# Replace the original file with the modified one
cp "$TEMP_FILE" "$SETTINGS_FILE"
rm "$TEMP_FILE"

echo "Updated settings.json with Treesitter commands in the main VSpaceCode menu"
