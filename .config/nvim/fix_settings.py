#!/usr/bin/env python3
import json
import re
import sys
import os
from pathlib import Path

def normalize_paths(obj):
    """Convert Windows paths to Unix paths and normalize separators"""
    if isinstance(obj, str):
        # Convert Windows paths to forward slashes
        return obj.replace('\\\\', '/').replace('\\', '/')
    elif isinstance(obj, dict):
        return {k: normalize_paths(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [normalize_paths(item) for item in obj]
    return obj

def strip_comments(json_str):
    """Remove JSON comments"""
    # First, handle any file metadata comments at the start
    json_str = re.sub(r'^//[^\n]*\n', '', json_str)
    
    # Process the rest line by line to handle // comments
    lines = []
    for line in json_str.splitlines():
        # Remove // comments, preserving the content before them
        line = re.sub(r'\s*//.*$', '', line)
        if line.strip():  # Only keep non-empty lines
            lines.append(line)
    
    # Join lines back together
    json_str = '\n'.join(lines)
    
    # Remove /* */ comments (including multi-line)
    json_str = re.sub(r'/\*.*?\*/', '', json_str, flags=re.DOTALL)
    
    return json_str

def clean_control_chars(json_str):
    """Remove control characters except newlines and tabs"""
    # First pass: remove common control characters
    json_str = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', json_str)
    
    # Second pass: ensure only printable characters remain (except newlines and tabs)
    return ''.join(char for char in json_str if char.isprintable() or char in '\n\t')

def clean_whitespace(json_str):
    """Clean up whitespace issues and fix common JSON syntax errors"""
    lines = []
    in_string = False
    escape_next = False
    quote_char = None
    
    for line in json_str.splitlines():
        # Process the line character by character to handle strings properly
        new_chars = []
        i = 0
        while i < len(line):
            char = line[i]
            
            if escape_next:
                new_chars.append(char)
                escape_next = False
            elif char == '\\':
                new_chars.append(char)
                escape_next = True
            elif char in ('"', "'"):
                if not in_string:
                    in_string = True
                    quote_char = char
                    new_chars.append('"')  # Always use double quotes
                elif char == quote_char:
                    in_string = False
                    quote_char = None
                    new_chars.append('"')  # Always use double quotes
                else:
                    new_chars.append(char)
            else:
                new_chars.append(char)
            
            i += 1
        
        # If we're still in a string at the end of the line, close it
        if in_string:
            new_chars.append('"')
            in_string = False
            quote_char = None
        
        # Remove trailing whitespace and normalize indentation
        line = ''.join(new_chars).rstrip()
        line = re.sub(r'^\t+', lambda m: '  ' * len(m.group()), line)
        
        if line:
            # Add missing commas if needed
            if lines and not line.lstrip().startswith((':', ',', '}', ']')):
                prev = lines[-1].rstrip()
                if prev and not prev.endswith((',', '{', '[')):
                    lines[-1] = prev + ','
            
            lines.append(line)
    
    return '\n'.join(lines)

def debug_json_error(content, error):
    """Print helpful debug info about JSON parsing errors"""
    lines = content.splitlines()
    error_line = error.lineno - 1  # Convert to 0-based index
    start_line = max(0, error_line - 2)
    end_line = min(len(lines), error_line + 3)
    
    print("\nContext around error:")
    for i in range(start_line, end_line):
        prefix = ">>> " if i == error_line else "    "
        print(f"{prefix}Line {i + 1}: {lines[i]}")
    print(f"\nError position: line {error.lineno}, column {error.colno}")
    
    # Show the exact character causing issues if possible
    if error.pos < len(content):
        char = content[error.pos]
        print(f"Character at error position: {repr(char)} (ASCII: {ord(char)})")

def fix_settings_file(file_path):
    backup_path = f"{file_path}.bak"
    
    # Create backup if it doesn't exist
    if not os.path.exists(backup_path):
        with open(file_path, 'rb') as f:  # Open in binary mode
            with open(backup_path, 'wb') as backup:
                backup.write(f.read())
    
    try:
        # Read file in binary mode first
        with open(file_path, 'rb') as f:
            content = f.read()
            
        # Try to decode as UTF-8, replacing invalid chars
        content = content.decode('utf-8', errors='replace')
        
        # Clean the content
        content = clean_control_chars(content)
        content = strip_comments(content)
        content = clean_whitespace(content)
        
        # Parse the JSON
        try:
            data = json.loads(content)
        except json.JSONDecodeError as e:
            print("JSON parsing failed.")
            debug_json_error(content, e)
            sys.exit(1)
        
        # Normalize paths
        data = normalize_paths(data)
        
        # Write back the cleaned JSON
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print("Successfully cleaned and fixed settings.json")
        return True
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

if __name__ == '__main__':
    settings_path = "/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"
    fix_settings_file(settings_path)
