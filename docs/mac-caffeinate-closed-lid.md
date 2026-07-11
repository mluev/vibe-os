# Keep a MacBook awake with the lid closed

Use this when you want long-running work (Cursor agents, Claude Code, builds, local model jobs) to continue after closing the lid.

## The problem with plain `caffeinate`

macOS has two separate sleep paths:

1. **Idle sleep** — triggered by inactivity timers. `caffeinate` blocks this.
2. **Lid-close sleep** — triggered by the lid sensor via `IOPMrootDomain`. `caffeinate` does **not** block this.

So `caffeinate -dims` alone is not enough for a closed-lid workflow.

## The fix

Enable the kernel `SleepDisabled` flag via `pmset`, then run `caffeinate` for additional protection:

```bash
sudo pmset -a disablesleep 1   # blocks lid-close sleep
caffeinate -dims                 # blocks idle, disk, display, and AC system sleep
```

This repo ships a script that wraps both steps.

## Quick start

On your Mac, from this repository:

```bash
chmod +x scripts/mac/caffeinate-closed-lid.sh
./scripts/mac/caffeinate-closed-lid.sh enable
```

Close the lid. Your Mac should stay awake.

When finished:

```bash
./scripts/mac/caffeinate-closed-lid.sh disable
```

Check state at any time:

```bash
./scripts/mac/caffeinate-closed-lid.sh status
```

## Persist across reboot

To re-enable automatically at login:

```bash
./scripts/mac/caffeinate-closed-lid.sh install
```

Remove it:

```bash
./scripts/mac/caffeinate-closed-lid.sh uninstall
```

The install step creates `~/Library/LaunchAgents/com.user.caffeinate-closed-lid.plist` and enables keep-awake immediately.

## Verify it is working

Before closing the lid:

```bash
pmset -g custom | grep -i sleepdisabled
# sleepdisabled          1

./scripts/mac/caffeinate-closed-lid.sh status
# SleepDisabled: ON
```

After your task, confirm sleep is restored:

```bash
./scripts/mac/caffeinate-closed-lid.sh disable
pmset -g custom | grep -i sleepdisabled
# sleepdisabled          0
```

For deeper inspection:

```bash
pmset -g assertions
```

## Safety notes

| Risk | Mitigation |
|---|---|
| Battery drain | Do not leave enabled on battery unattended. Run `disable` when done. |
| Overheating in a bag | Never store a closed, awake MacBook in a backpack or sleeve. |
| Forgot to turn off | Prefer `install` only for desk setups on AC power. Use `status` before walking away. |

Apple does not officially support closed-lid operation without an external display (clamshell mode). This setup uses a supported `pmset` flag, but you are responsible for thermals and battery life.

## Manual one-liners (without the script)

Enable:

```bash
sudo pmset -a disablesleep 1
caffeinate -dims &
```

Disable:

```bash
sudo pmset -a disablesleep 0
kill %1   # or: pkill -f "caffeinate -dims"
```

## GUI alternatives

If you prefer a menu-bar toggle instead of Terminal:

- [Sleepless](https://github.com/Aboudjem/Sleepless) — open source, uses `pmset disablesleep`
- [Amphetamine](https://apps.apple.com/app/amphetamine/id937984704) — long-standing, closed source
- [KeepingYouAwake](https://github.com/newmarcel/KeepingYouAwake) — good for idle sleep only, **not** lid-close

## Troubleshooting

**Mac still sleeps when lid closes**

1. Confirm `SleepDisabled` is on: `pmset -g custom | grep -i sleepdisabled`
2. Re-run `sudo pmset -a disablesleep 1`
3. Check for conflicting power tools: `pmset -g assertions`

**`caffeinate` exits immediately**

The script stores the PID in `~/.caffeinate-closed-lid.pid`. Check logs at `~/Library/Logs/caffeinate-closed-lid/`.

**Permission denied on `pmset`**

`disablesleep` requires administrator privileges. The script will prompt for your password once per session.

**Low Power Mode**

macOS may still throttle background work in Low Power Mode even if sleep is disabled. Disable Low Power Mode for critical long jobs.
