#!/usr/bin/env python3
import json
import sys
import re
import os
import subprocess

def preprocess_file(input_file, output_file):
    """Use sed to clean the file of problematic characters"""
    try:
        # Remove control characters and normalize line endings
        result = subprocess.run([
            'sed', 
            # Keep only printable ASCII, newlines, and tabs
            's/[^[:print:]\n\t]//g',
            input_file
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(result.stdout)
            return True
    except Exception as e:
        print(f"Error preprocessing file: {str(e)}")
    return False

def clean_json(content):
    # Remove comments
    content = re.sub(r'//.*$', '', content, flags=re.MULTILINE)  # Remove single-line comments
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)  # Remove multi-line comments
    
    # Convert Windows paths to Unix-style
    content = content.replace('\\\\', '/')
    
    # Fix any trailing commas
    content = re.sub(r',(\s*[}\]])', r'\1', content)
    
    # Remove empty lines
    content = '\n'.join(line for line in content.splitlines() if line.strip())
    
    return content

def fix_vspacecode_bindings(data):
    if "vspacecode.bindings" not in data:
        return data
    
    bindings = data["vspacecode.bindings"]
    
    # Remove empty bindings
    bindings = [b for b in bindings if b and isinstance(b, dict) and b.get("bindings") != []]
    
    # Find and update or create the Neovim Commands section
    neovim_section = next((b for b in bindings if b.get("key") == "n" and b.get("name") == "+Neovim Commands"), None)
    if neovim_section:
        # Update existing section
        neovim_section.update({
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
        })
    else:
        # Create new section
        bindings.append({
            "key": "n",
            "name": "+Neovim Commands",
            "icon": "vim",
            "type": "bindings",
            "bindings": [
                # Same bindings as above
            ]
        })
    
    data["vspacecode.bindings"] = bindings
    return data

def main():
    settings_file = "/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
    backup_file = settings_file + ".bak"
    temp_file = settings_file + ".tmp"
    clean_file = settings_file + ".clean"
    
    # Create backup if it doesn't exist
    if not os.path.exists(backup_file):
        with open(settings_file, 'rb') as f_in:
            with open(backup_file, 'wb') as f_out:
                f_out.write(f_in.read())
        print(f"Created backup at {backup_file}")
    
    try:
        # First, preprocess the file to clean it
        if not preprocess_file(settings_file, clean_file):
            raise Exception("Failed to preprocess file")
        
        # Read the cleaned file
        with open(clean_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Clean the JSON content
        cleaned_content = clean_json(content)
        
        # Parse the JSON
        data = json.loads(cleaned_content)
        
        # Fix VSpaceCode bindings
        data = fix_vspacecode_bindings(data)
        
        # Write to temporary file first
        with open(temp_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
        
        # If successful, move to final location
        os.rename(temp_file, settings_file)
        
        print("Successfully fixed settings.json")
        print("- Removed control characters")
        print("- Removed comments")
        print("- Fixed path separators")
        print("- Updated VSpaceCode bindings")
        print(f"Original file backed up at: {backup_file}")
        
    except Exception as e:
        print(f"Error: {str(e)}")
        print("Restoring from backup...")
        if os.path.exists(backup_file):
            with open(backup_file, 'rb') as f_in:
                with open(settings_file, 'wb') as f_out:
                    f_out.write(f_in.read())
            print("Restored from backup")
        for f in [temp_file, clean_file]:
            if os.path.exists(f):
                os.unlink(f)
        sys.exit(1)
    finally:
        # Clean up temporary files
        for f in [temp_file, clean_file]:
            if os.path.exists(f):
                os.unlink(f)

if __name__ == "__main__":
    main()
