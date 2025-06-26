#!/bin/zsh

# This script checks the VSpaceCode setup and troubleshoots common issues
echo "VSpaceCode Troubleshooting Script"
echo "================================="
echo ""

# Check if the required extensions are installed
echo "Checking installed extensions..."
VSPACECODE_INSTALLED=$(code --list-extensions | grep -c "vspacecode.vspacecode")
WHICHKEY_INSTALLED=$(code --list-extensions | grep -c "vspacecode.whichkey")

if [ $VSPACECODE_INSTALLED -eq 1 ] && [ $WHICHKEY_INSTALLED -eq 1 ]; then
    echo "✅ VSpaceCode and WhichKey extensions are installed"
else
    echo "❌ Missing required extensions!"
    if [ $VSPACECODE_INSTALLED -eq 0 ]; then
        echo "   - vspacecode.vspacecode is not installed"
        echo "   - Run: code --install-extension vspacecode.vspacecode"
    fi
    if [ $WHICHKEY_INSTALLED -eq 0 ]; then
        echo "   - vspacecode.whichkey is not installed"
        echo "   - Run: code --install-extension vspacecode.whichkey"
    fi
    echo ""
fi

# Check keybindings.json
echo "Checking keybindings.json..."
KEYBINDINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/keybindings.json"

if [ -f "$KEYBINDINGS_FILE" ]; then
    SPACE_BINDING=$(jq -r '.[] | select(.key == "space") | .command' "$KEYBINDINGS_FILE")
    if [ "$SPACE_BINDING" == "vspacecode.space" ]; then
        echo "✅ Space key is mapped to vspacecode.space"
        
        SPACE_WHEN=$(jq -r '.[] | select(.key == "space") | .when' "$KEYBINDINGS_FILE")
        echo "   - When condition: $SPACE_WHEN"
    else
        echo "❌ Space key is not correctly mapped!"
        echo "   - Current mapping: $SPACE_BINDING"
        echo "   - Should be: vspacecode.space"
    fi
else
    echo "❌ keybindings.json file not found at $KEYBINDINGS_FILE"
fi
echo ""

# Check settings.json
echo "Checking settings.json..."
SETTINGS_FILE="/home/fedusr/.config/Code/User/profiles/-5cba1ddc/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    # Check WhichKey bindings
    WHICHKEY_BINDINGS_COUNT=$(jq '.["whichkey.bindings"] | length' "$SETTINGS_FILE")
    if [ "$WHICHKEY_BINDINGS_COUNT" -gt 0 ]; then
        echo "✅ whichkey.bindings has $WHICHKEY_BINDINGS_COUNT bindings defined"
    else
        echo "❌ whichkey.bindings is empty! Run setup_vspacecode_bindings.sh"
    fi
    
    # Check WhichKey delay
    WHICHKEY_DELAY=$(jq '.["whichkey.delay"]' "$SETTINGS_FILE")
    if [ "$WHICHKEY_DELAY" != "null" ]; then
        echo "✅ whichkey.delay is set to $WHICHKEY_DELAY ms"
    else
        echo "❌ whichkey.delay is not defined"
    fi
    
    # Check sort order
    WHICHKEY_SORT=$(jq -r '.["whichkey.sortOrder"]' "$SETTINGS_FILE")
    if [ "$WHICHKEY_SORT" != "null" ]; then
        echo "✅ whichkey.sortOrder is set to $WHICHKEY_SORT"
    else
        echo "❌ whichkey.sortOrder is not defined"
    fi
else
    echo "❌ settings.json file not found at $SETTINGS_FILE"
fi
echo ""

# Neovim configuration
echo "Checking Neovim configuration..."
VSCODE_LUA="/home/fedusr/.config/nvim/lua/config/vscode.lua"

if [ -f "$VSCODE_LUA" ]; then
    if grep -q "vim.g.vscode_space_handled_by_vspacecode" "$VSCODE_LUA"; then
        echo "✅ vscode_space_handled_by_vspacecode is set in vscode.lua"
    else
        echo "❌ vscode_space_handled_by_vspacecode is not set in vscode.lua"
        echo "   Add this line: vim.g.vscode_space_handled_by_vspacecode = true"
    fi
else
    echo "❌ vscode.lua file not found at $VSCODE_LUA"
fi
echo ""

echo "Restart VS Code for all changes to take effect!"
echo "If VSpaceCode menu still doesn't work after restarting, try reinstalling the extensions:"
echo "code --uninstall-extension vspacecode.vspacecode"
echo "code --uninstall-extension vspacecode.whichkey"
echo "code --install-extension vspacecode.whichkey"
echo "code --install-extension vspacecode.vspacecode"
