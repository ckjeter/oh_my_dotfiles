#!/bin/sh
# Schedule the daily agent session backup: a systemd user timer on Linux, a
# launchd agent on macOS.
#
# It only wires the schedule. The encrypted rclone remote is created by hand
# (see backup/README.md), because its password must never pass through a
# script, a repo, or an agent transcript. Until that remote exists this
# reports what is missing and schedules nothing.
set -e
. "$(dirname "$0")/../scripts/lib.sh"

remote="${AGENT_BACKUP_REMOTE:-agentbak:}"
script="$DOTFILES/backup/agent-backup.sh"

if ! have rclone; then
  echo "rclone is missing, agent backup not scheduled. See backup/README.md"
  exit 0
fi
if ! rclone listremotes 2> /dev/null | grep -qxF "$remote"; then
  echo "rclone remote '$remote' does not exist, agent backup not scheduled. See backup/README.md"
  exit 0
fi

# write stdin to a file, report whether it changed
write_if_changed() {
  _dst="$1"
  _tmp="$_dst.dotfiles-tmp"
  mkdir -p "$(dirname "$_dst")"
  cat > "$_tmp"
  if [ -f "$_dst" ] && cmp -s "$_tmp" "$_dst"; then
    rm -f "$_tmp"
    return 1
  fi
  mv "$_tmp" "$_dst"
  return 0
}

case "$(os_family)" in
  linux)
    have systemctl || { echo "no systemctl, agent backup not scheduled"; exit 0; }
    dir="$HOME/.config/systemd/user"
    changed=0
    write_if_changed "$dir/agent-backup.service" << EOF && changed=1
[Unit]
Description=Encrypted backup of agent session data

[Service]
Type=oneshot
Nice=10
ExecStart=/bin/sh $script
EOF
    write_if_changed "$dir/agent-backup.timer" << 'EOF' && changed=1
[Unit]
Description=Daily encrypted backup of agent session data

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF
    if [ "$changed" -eq 1 ]; then
      systemctl --user daemon-reload
      echo "agent backup timer written"
    fi
    systemctl --user enable --now agent-backup.timer > /dev/null 2>&1 \
      || echo "could not enable agent-backup.timer, no user systemd session here"
    ;;
  macos)
    label=com.oh-my-dotfiles.agent-backup
    plist="$HOME/Library/LaunchAgents/$label.plist"
    if write_if_changed "$plist" << EOF; then
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key>
  <array><string>/bin/sh</string><string>$script</string></array>
  <key>EnvironmentVariables</key>
  <dict><key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string></dict>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>13</integer><key>Minute</key><integer>30</integer></dict>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/agent-backup.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/agent-backup.log</string>
</dict>
</plist>
EOF
      launchctl bootout "gui/$(id -u)/$label" 2> /dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$plist" 2> /dev/null \
        || echo "could not load $label, run this from a logged-in session"
      echo "agent backup launchd agent written"
    fi
    ;;
esac
