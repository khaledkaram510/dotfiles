#!/bin/zsh

# This script sorts VSpaceCode bindings and removes duplicate Neovim commands
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json.bak"

# Create a backup if it doesn't exist
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "Created backup of settings.json"
fi

# Create a temporary file
TEMP_FILE=$(mktemp)

# Sort and clean up bindings using jq
jq '
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

  def process_bindings:
    sort_by(sort_key) |
    map(
      if .bindings then
        . + {bindings: (.bindings | process_bindings)}
      else
        .
      end
    );

  def remove_duplicates:
    . as $root |
    reduce range(length) as $i ([]; 
      . + [
        if $i > 0 and ($root[$i].name == $root[0:$i] | map(.name) | any(. == $root[$i].name)) then
          empty
        else
          $root[$i]
        end
      ]
    );

  # Process whichkey.bindings if it exists
  if has("whichkey.bindings") then
    .["whichkey.bindings"] |= (
      remove_duplicates | 
      process_bindings
    )
  else
    .
  end |
  
  # Process vspacecode.bindings if it exists (for backward compatibility)
  if has("vspacecode.bindings") then
    .["vspacecode.bindings"] |= (
      remove_duplicates |
      process_bindings
    )
  else
    .
  end
' "$SETTINGS_FILE" > "$TEMP_FILE"

# Check if jq succeeded
if [ $? -eq 0 ]; then
    # Replace the original file with the sorted version
    mv "$TEMP_FILE" "$SETTINGS_FILE"
    echo "Successfully sorted VSpaceCode bindings:"
    echo "- Special characters first"
    echo "- Lowercase letters a-z"
    echo "- Uppercase letters A-Z"
    echo "- Numbers"
    echo "- Removed duplicate +Neovim Commands sections"
    echo ""
    echo "Original file backed up at: $BACKUP_FILE"
else
    rm "$TEMP_FILE"
    echo "Error: Failed to sort settings.json"
    echo "Please check the file manually"
fi
