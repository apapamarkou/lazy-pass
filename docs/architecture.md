# Architecture

## Overview

lazy-pass is a modular Bash CLI tool layered over `pass`. Each concern lives in its own file under `lib/`.

```
bin/pass-ui          ← entrypoint: sources libs, checks deps, routes to UI or pass
lib/
  validation.sh      ← pure validation functions (no side effects)
  utils.sh           ← clipboard, password gen, OS detection, logging
  backend.sh         ← pass wrapper: list, show, insert, delete, parse
  ui.sh              ← fzf UI: main screen, new entry, edit entry
```

## Data Flow

```
passwords (symlink)
  └─ bin/pass-ui
       ├─ args present? → exec pass "$@"
       └─ no args       → ui_main()
                              ├─ backend_list()       → fzf list
                              ├─ _preview_entry()     → fzf preview (password masked)
                              ├─ ctrl-p/u/b           → copy_to_clipboard()
                              ├─ enter                → ui_edit_entry()
                              └─ ctrl-n               → ui_new_entry()
```

## Entry Format

```
<PASSWORD>
username: <value>
url: <value>
email: <value>
otp: <value>
notes: <value>
```

Stored as a `pass` entry (GPG-encrypted file in `~/.password-store`).

## Security Notes

- Passwords are never logged or echoed in plaintext (masked as `******` in preview)
- Clipboard writes use `printf '%s'` to avoid shell injection via `echo`
- Temp files created with `mktemp` and cleaned up via `trap EXIT`
- `set -euo pipefail` in all scripts prevents silent failures

## Dependency Layers

```
validation.sh   ← no deps
utils.sh        ← no internal deps
backend.sh      ← requires: pass, utils.sh (for log_error)
ui.sh           ← requires: backend.sh, utils.sh, validation.sh
bin/pass-ui     ← sources all of the above
```
