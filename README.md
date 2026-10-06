# alpha-tmux

Tmux plugin that automatically captures pentest commands and output across all
panes and sends them to an [Alpha](https://github.com/alpha-security/alpha) server.

Works by injecting `al shell --init` hooks into each tmux pane — allowlisted
tools (nmap, ffuf, nuclei, etc.) get full stdout capture; everything else gets
metadata-only recording (command, timing, exit code). All data ships via the
existing `al` collector binary (auth, offline spool, retry handled for you).

## Requirements

- tmux 3.0+
- The `al` collector binary, enrolled against an Alpha server
  (`al enroll <server-url>`)

## Installation

### With [TPM](https://github.com/tmux-plugins/tpm)

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'shoamshilo/alpha-tmux'
```

Press `prefix + I` to install.

### Manual

```bash
git clone https://github.com/shoamshilo/alpha-tmux ~/.tmux/plugins/alpha-tmux
```

Add to `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/alpha-tmux/alpha.tmux
```

Reload: `tmux source-file ~/.tmux.conf`

## Configuration

All options are set via tmux user options in `~/.tmux.conf`:

| Option | Default | Description |
|---|---|---|
| `@alpha-capture` | `on` | Global enable/disable |
| `@alpha-key-toggle` | `A` | Key (after prefix) to toggle per-pane capture |
| `@alpha-al-bin` | `al` | Path to the `al` binary |

Example:

```tmux
set -g @alpha-key-toggle 'A'
set -g @alpha-al-bin '/usr/local/bin/al'
```

### Status bar

Add the status segment to see capture state per pane:

```tmux
set -g status-right '#(~/.tmux/plugins/alpha-tmux/scripts/status.sh) %H:%M'
```

Shows `AL:on` (green) or `AL:off` (grey).

## Usage

Once installed, all new and existing panes are automatically hooked. Commands
you run are captured and sent to Alpha with full tmux context (session, window,
pane).

### Toggle capture per pane

Press `prefix + A` (default) to toggle capture off/on for the current pane.

### How capture works

| Tool type | Example | Capture tier |
|---|---|---|
| Allowlisted tool | `nmap -sV 10.0.0.1` | Full stdout via `al run` |
| Other command | `python3 exploit.py` | Metadata only via `al run --record-only` |
| Shell builtin | `cd /tmp` | Skipped |

The allowlist matches `al shell`'s default set: nmap, masscan, rustscan, naabu,
ffuf, gobuster, feroxbuster, dirb, katana, nuclei, httpx, nikto, whatweb,
wpscan, netexec, nxc, crackmapexec, enum4linux, enum4linux-ng, smbmap, dnsx,
subfinder, amass, dnsrecon, kerbrute, hydra.

## License

MIT
