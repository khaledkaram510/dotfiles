#!/bin/zsh

# Define the markers for the insertion
FIND_PATTERN='"key": " ",'
INSERTION_CONTENT='{
      "key": "f",
      "name": "Quick Open (Neovim)",
      "icon": "go-to-file",
      "type": "command",
      "command": "vscode-neovim.send",
      "args": ":VSQuickOpen<CR>"
    },
    {
      "key": "/",
      "name": "Find in Files (Neovim)",
      "icon": "search",
      "type": "command",
      "command": "vscode-neovim.send",
      "args": ":VSFindInFiles<CR>"
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

echo "Updated settings.json with Quick Open and Find in Files in the main VSpaceCode menu"
