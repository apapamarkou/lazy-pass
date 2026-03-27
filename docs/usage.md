# Usage

## Launch

```bash
passwords          # open interactive UI
passwords ls       # forward to: pass ls
passwords show foo # forward to: pass show foo
```

## Main Screen

| Key       | Action                  |
|-----------|-------------------------|
| `Enter`   | Edit selected entry     |
| `Ctrl-N`  | Create new entry        |
| `Ctrl-P`  | Copy password           |
| `Ctrl-U`  | Copy URL                |
| `Ctrl-B`  | Copy username           |
| `Ctrl-Q`  | Quit                    |
| `ESC`     | Quit                    |

The preview pane (right side) shows all fields with the password masked as `******`.

## Creating an Entry

1. Press `Ctrl-N`
2. Enter a name (e.g. `github/personal`)
3. Choose auto-generate or enter a password manually
4. Fill in username (required), URL, email, OTP secret, notes
5. Confirm to save

## Editing an Entry

1. Select an entry and press `Enter`
2. Use arrow keys to select a field
3. Press `Enter` to edit the selected field
4. Changes are saved to `pass` immediately after each field edit
5. Press `Ctrl-Q` or `ESC` to return to the main screen

## Password Rules

- Minimum 8 characters
- Must contain: uppercase, lowercase, digit, symbol

## OTP Secret Format

Must be valid base32 (characters A–Z and 2–7, optional `=` padding).

## Uninstall

```bash
bash uninstall
```

Or via curl:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/lazy-pass/main/uninstall | bash
```

## Clipboard

Clipboard support is automatic:
- **Linux (Wayland):** `wl-copy`
- **Linux (X11):** `xclip`
- **macOS:** `pbcopy`
