# claude-code-notify-plugin

Bash hooks that POST to a webhook URL whenever Claude needs you:

- **Notification** — permission prompts and AskUserQuestion dialogs (matcher: `permission_prompt|elicitation_dialog`).
- **PreToolUse:ExitPlanMode** — when Claude exits plan mode and waits for plan approval.
- **Stop** — when Claude finishes a turn.

## Install

In Claude Code:

```
/plugin marketplace add Mocha--/claude-code-notify-plugin
/plugin install claude-code-notify-plugin@mocha-plugins
```

Or from a local checkout for development:

```
/plugin marketplace add /path/to/claude-code-notify-plugin
/plugin install claude-code-notify-plugin@mocha-plugins
```

## Configure

Set the webhook URL in your environment (e.g. `~/.zshrc`, `~/.bashrc`, or `~/.claude/settings.json` `env`):

```bash
export CLAUDE_NOTIFY_WEBHOOK_URL="https://hooks.slack.com/triggers/..."
export CLAUDE_NOTIFY_ORIGIN="🌰 Devbox"   # optional, defaults to "Claude Code"
```

If `CLAUDE_NOTIFY_WEBHOOK_URL` is unset, hooks no-op silently.

## Payload

```json
{"origin": "🌰 Devbox", "message": "🚨 Waiting for input"}
{"origin": "🌰 Devbox", "message": "✅ Complete"}
```

Works with anything that accepts `POST application/json` — Slack workflow triggers, Discord webhooks (with adjusted shape), ntfy, custom servers.

## Requirements

`bash` and `curl`. That's it.
