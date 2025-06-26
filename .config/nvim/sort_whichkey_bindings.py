#!/usr/bin/env python3

import json
import os
import sys
import time

# This script sorts WhichKey bindings and removes duplicate sections
SETTINGS_FILE = "/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
BACKUP_FILE = f"{SETTINGS_FILE}.{time.strftime('%Y%m%d%H%M%S')}.bak"

print(f"Creating backup of settings.json at {BACKUP_FILE}")
os.system(f"cp '{SETTINGS_FILE}' '{BACKUP_FILE}'")

# Sort function based on key pattern: special chars, lowercase, uppercase, numbers
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

# Recursively sort nested bindings
def sort_bindings(bindings):
    if not bindings or not isinstance(bindings, list):
        return bindings
    
    # Sort the current level
    sorted_bindings = sorted(bindings, key=sort_key)
    
    # Recursively sort nested bindings
    for binding in sorted_bindings:
        if "bindings" in binding and isinstance(binding["bindings"], list):
            binding["bindings"] = sort_bindings(binding["bindings"])
    
    return sorted_bindings

# Remove duplicate sections (like multiple +Neovim sections)
def remove_duplicates(bindings):
    if not bindings or not isinstance(bindings, list):
        return bindings
    
    seen_names = set()
    unique_bindings = []
    
    for binding in bindings:
        name = binding.get("name", "")
        if name and name in seen_names:
            # Skip duplicate section
            continue
        
        seen_names.add(name)
        unique_bindings.append(binding)
        
        # Also check for duplicates in nested bindings
        if "bindings" in binding and isinstance(binding["bindings"], list):
            binding["bindings"] = remove_duplicates(binding["bindings"])
    
    return unique_bindings

try:
    # Read the settings file
    with open(SETTINGS_FILE, 'r') as f:
        settings = json.load(f)
    
    # Process whichkey.bindings if it exists
    if "whichkey.bindings" in settings and isinstance(settings["whichkey.bindings"], list):
        settings["whichkey.bindings"] = remove_duplicates(settings["whichkey.bindings"])
        settings["whichkey.bindings"] = sort_bindings(settings["whichkey.bindings"])
        print("Processed whichkey.bindings")
    
    # Process vspacecode.bindings if it exists (for backward compatibility)
    if "vspacecode.bindings" in settings and isinstance(settings["vspacecode.bindings"], list):
        settings["vspacecode.bindings"] = remove_duplicates(settings["vspacecode.bindings"])
        settings["vspacecode.bindings"] = sort_bindings(settings["vspacecode.bindings"])
        print("Processed vspacecode.bindings")
    
    # Write the updated settings back to the file
    with open(SETTINGS_FILE, 'w') as f:
        json.dump(settings, f, indent=2)
    
    print("Successfully sorted WhichKey bindings:")
    print("- Special characters first")
    print("- Lowercase letters a-z")
    print("- Uppercase letters A-Z")
    print("- Numbers")
    print("- Removed duplicate sections")
    print("")
    print(f"Original file backed up at: {BACKUP_FILE}")
    
except Exception as e:
    print(f"Error: {str(e)}")
    print("Failed to sort settings.json")
    print("Please check the file manually")
    print(f"Original file backed up at: {BACKUP_FILE}")
    sys.exit(1)
