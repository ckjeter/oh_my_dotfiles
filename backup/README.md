# backup/

Daily encrypted copy of agent session data to cloud storage, one folder per
machine. Nothing else backs these files up, and the leader ledger analysis
depends on the raw transcripts.

## What is copied

| Source | Folder in the backup |
|--------|----------------------|
| `~/.claude/projects`, `~/.claude/history.jsonl` | `claude/` |
| `~/.codex/sessions`, `archived_sessions`, `history.jsonl`, `session_index.jsonl` | `codex/` |
| `~/.pi/agent/sessions` | `pi/` |
| `~/.local/share/leader` | `leader/` |
| agent-deck `state.db` per profile, as a consistent SQLite snapshot | `agent-deck/` |

`rclone copy`, never `sync`. A file deleted locally stays in the backup.

The folder is named after the machine: `hostname -s` on Linux, the computer
name on macOS. Set `AGENT_BACKUP_NAME` to override it.

## One-time setup per machine

The script refuses to run unless its remote is an rclone `crypt` remote. Create
it by hand in a plain terminal, outside any agent session, so the password
never lands in a transcript:

```
rclone config
  n) New remote
  name> agentbak
  Storage> crypt
  remote> <your drive remote>:agent-backup
  filename_encryption> standard
  directory_name_encryption> true
  password> y, then paste the password
  password2 (salt)> y, then paste the salt
```

Generate the password and the salt in the password manager first and paste
them into the hidden prompts. Every machine uses the same pair. Lose them and
the backup is unreadable: `rclone.conf` holds them only in obscured form, and
that file dies with the machine.

Then run `sh backup/install.sh`, or the root installer, to schedule it.

## Running and checking

```
sh backup/agent-backup.sh --dry-run
sh backup/agent-backup.sh

systemctl --user list-timers agent-backup.timer     # Linux
journalctl --user -u agent-backup.service -n 50
tail ~/Library/Logs/agent-backup.log                # macOS
```

## Restore

```
rclone copy agentbak:<machine>/claude/projects ./restored
```

On a new machine, recreate the drive remote and the `agentbak` crypt remote
with the same password and salt first.
