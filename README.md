# lazy-pass

A modular, interactive terminal UI for [`pass`](https://www.passwordstore.org/) — the standard Unix password manager.

## Features

- Interactive `fzf`-based UI with live preview
- Create, edit, and copy passwords without leaving the terminal
- Cross-platform clipboard support (Linux X11/Wayland, macOS)
- Auto-generates strong passwords
- Validates all inputs (password strength, URL format, OTP base32)
- Forwards any arguments directly to `pass`
- Fully modular Bash — shellcheck clean

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/apapamarkou/lazy-pass/main/install | bash
```

Installs to:
- `~/.local/share/lazy-pass/`
- `~/.local/bin/passwords` (symlink)

## Dependencies

| Tool       | Purpose              |
|------------|----------------------|
| `pass`     | Password store       |
| `fzf`      | Interactive UI       |
| `gpg`      | Encryption           |
| `git`      | Version control      |
| `xclip` or `wl-clipboard` | Clipboard (Linux) |

The installer will detect missing dependencies and offer to install them.

## Usage

```bash
passwords          # launch UI
passwords ls       # pass ls
passwords show foo # pass show foo
```

See [docs/usage.md](docs/usage.md) for full keybinding reference.

## Keybindings

| Key      | Action           |
|----------|------------------|
| `Enter`  | Edit entry       |
| `Ctrl-N` | New entry        |
| `Ctrl-P` | Copy password    |
| `Ctrl-U` | Copy URL         |
| `Ctrl-B` | Copy username    |
| `Ctrl-Q` | Quit             |
| `ESC`    | Quit             |

## Entry Format

```
<PASSWORD>
username: <value>
url: <value>
email: <value>
otp: <value>
notes: <value>
```

## Uninstall

```bash
bash uninstall
```

Or via curl:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/lazy-pass/main/uninstall | bash
```

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).

## Architecture

See [docs/architecture.md](docs/architecture.md).

## Development

```bash
make test    # run bats tests
make lint    # shellcheck
make fmt     # shfmt
make check   # lint + test
```

