#!/bin/bash

# Script to update WhichKey bindings and sort them

echo "===== Updating WhichKey Bindings ====="
echo "This script will:"
echo "1. Add Neovim, Copilot, and Docker sections to WhichKey menu"
echo "2. Sort all bindings according to the pattern:"
echo "   - Special characters first"
echo "   - Lowercase letters a-z" 
echo "   - Uppercase letters A-Z"
echo "   - Numbers"
echo "3. Remove any duplicate sections"
echo ""

echo "Step 1: Adding new bindings sections..."
/home/fedusr/.config/nvim/add_whichkey_bindings.sh

echo ""
echo "Step 2: Sorting all WhichKey bindings..."
/home/fedusr/.config/nvim/sort_whichkey_bindings.py

echo ""
echo "Step 3: Restarting VS Code to apply changes..."
/home/fedusr/.config/nvim/restart_vscode.sh

echo ""
echo "All tasks completed! VS Code will restart with the updated WhichKey bindings."
