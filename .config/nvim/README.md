# Neovim + VSpaceCode + WhichKey Integration

This directory contains scripts for integrating Neovim with VSpaceCode and WhichKey in VS Code.

## Setup

1. Make sure VS Code has the following extensions installed:

   - vscode-neovim
   - vspacecode.whichkey
   - vspacecode.vspacecode

2. Run the setup script to initialize your configuration:
   ```bash
   ./update_keybindings.sh
   ```

## Key Scripts

- `update_keybindings.sh`: Main script that runs all necessary steps to set up the Neovim, Copilot, and Docker integration with VSpaceCode.
- `add_whichkey_bindings.sh`: Adds Neovim, Copilot, and Docker sections to the WhichKey menu.
- `sort_whichkey_bindings.py`: Sorts all bindings according to pattern (special chars, lowercase, uppercase, numbers) and removes duplicates.
- `restart_vscode.sh`: Restarts VS Code to apply changes.
- `debug_vspacecode.sh`: Diagnoses issues with VSpaceCode configuration.

## Keybindings Structure

The WhichKey menu has been organized with the following sections:

### Neovim Section (`SPC v`)

- `SPC v c`: Clear highlights
- `SPC v e`: Edit file
- `SPC v f`: Find file
- `SPC v w`: Write buffer (save)
- `SPC v q`: Quit buffer (close)
- `SPC v t`: Treesitter commands
  - `SPC v t s v`: Start visual selection
  - `SPC v t s i`: Incremental selection
  - `SPC v t s d`: Decremental selection
  - `SPC v t n`: Next function
  - `SPC v t p`: Previous function

### Copilot Section (`SPC c`)

- `SPC c c`: Open Copilot Chat
- `SPC c s`: Suggest code
- `SPC c a`: Accept suggestion
- `SPC c n`: Next suggestion
- `SPC c p`: Previous suggestion
- `SPC c d`: Dismiss suggestion

### Docker Section (`SPC d`)

- `SPC d b`: Build
- `SPC d c`: Compose Up
- `SPC d d`: Compose Down
- `SPC d i`: Images
- `SPC d r`: Run
- `SPC d s`: Start
- `SPC d S`: Stop
- `SPC d v`: View Logs

## Troubleshooting

If you encounter issues with the VSpaceCode menu:

1. Run the diagnostic script:

   ```bash
   ./debug_vspacecode.sh
   ```

2. Try restarting VS Code with cache clearing:

   ```bash
   ./restart_vscode.sh
   ```

3. Reinstall the VSpaceCode and WhichKey extensions if needed.

## Custom Commands

The integration includes custom Neovim commands that can be accessed from VSpaceCode:

- `:VSQuickOpen`: Open the VS Code quick open dialog
- `:VSFindInFiles`: Open the VS Code find in files dialog
- `:TSVisualSelection`: Start Treesitter visual selection
- `:TSIncremental`: Expand Treesitter selection
- `:TSDecremental`: Shrink Treesitter selection
