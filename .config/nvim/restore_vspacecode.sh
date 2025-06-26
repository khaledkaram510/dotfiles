#!/bin/zsh

# This script restores the original settings.json from the backup
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json.bak"

if [ -f "$BACKUP_FILE" ]; then
  cp "$BACKUP_FILE" "$SETTINGS_FILE"
  echo "Restored original settings.json from backup"
else
  echo "Backup file not found. Cannot restore."
fi
