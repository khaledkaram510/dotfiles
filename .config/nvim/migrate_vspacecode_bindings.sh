#!/bin/zsh

# This script migrates VSpaceCode bindings from settings.json to keybindings.json
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
KEYBINDINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/keybindings.json"
BACKUP_SETTINGS="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json.bak"
BACKUP_KEYBINDINGS="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/keybindings.json.bak"

# Create backups
cp "$SETTINGS_FILE" "$BACKUP_SETTINGS"
cp "$KEYBINDINGS_FILE" "$BACKUP_KEYBINDINGS"

# Extract VSpaceCode bindings and convert to keybindings format
jq '
  def binding_to_keybinding(prefix):
    . as $binding |
    if $binding.type == "command" then
      {
        "key": (prefix + " " + $binding.key),
        "command": $binding.command,
        "args": $binding.args,
        "when": "neovim.mode == normal"
      }
    elif $binding.type == "bindings" then
      ($binding.bindings | map(binding_to_keybinding(prefix + " " + $binding.key)) | add)
    else
      empty
    end;

  # Get vspacecode bindings from settings
  if has("vspacecode.bindings") then
    .["vspacecode.bindings"] | 
    map(binding_to_keybinding("space")) |
    add |
    [.[]]
  else
    []
  end
' "$SETTINGS_FILE" > "/tmp/vspacecode_keybindings.json"

# Merge with existing keybindings
jq -s '
  .[0] + .[1] |
  sort_by(.key)
' "$KEYBINDINGS_FILE" "/tmp/vspacecode_keybindings.json" > "/tmp/merged_keybindings.json"

# Update keybindings.json
mv "/tmp/merged_keybindings.json" "$KEYBINDINGS_FILE"

# Remove vspacecode bindings from settings.json
jq 'del(.["vspacecode.bindings"])' "$SETTINGS_FILE" > "/tmp/cleaned_settings.json"
mv "/tmp/cleaned_settings.json" "$SETTINGS_FILE"

echo "Successfully migrated VSpaceCode bindings to keybindings.json"
echo "Backups created at:"
echo "  $BACKUP_SETTINGS"
echo "  $BACKUP_KEYBINDINGS"
