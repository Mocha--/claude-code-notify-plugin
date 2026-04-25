# claude-code-notify-plugin

## Overview
Bash hooks that POST to a webhook URL whenever Claude needs you:

- **Notification** — permission prompts and AskUserQuestion dialogs (matcher: `permission_prompt|elicitation_dialog`).
- **PreToolUse:ExitPlanMode** — when Claude exits plan mode and waits for plan approval.
- **Stop** — when Claude finishes a turn.

## Install

In Claude Code.

### 1. Add the marketplace

```
/plugin marketplace add Mocha--/claude-code-notify-plugin
```

### 2. Install the plugin

```
/plugin install claude-code-notify-plugin@mocha-plugins
```

## Configure

Set environment variables in `~/.zshrc`, `~/.bashrc`, or `~/.claude/settings.json` `env`:

| Variable | Required | Description |
|---|---|---|
| `CLAUDE_NOTIFY_WEBHOOK_URL` | yes | Webhook URL. |
| `CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD` | yes | JSON body for `Notification` and `PreToolUse:ExitPlanMode`. POSTed verbatim. |
| `CLAUDE_NOTIFY_STOP_PAYLOAD` | yes | JSON body for `Stop`. POSTed verbatim. |

If any of these variables is missing, the hook exits non-zero and prints an error to stderr. Disable the plugin with `/plugin disable` if you want to silence it temporarily.

## Payload examples

Pick the shape your webhook expects:

```bash
export CLAUDE_NOTIFY_WEBHOOK_URL="https://hooks.slack.com/triggers/..."

# Slack workflow trigger
export CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD='{"origin":"🌰 Devbox","message":"🚨 Waiting for input"}'
export CLAUDE_NOTIFY_STOP_PAYLOAD='{"origin":"🌰 Devbox","message":"✅ Complete"}'

# Discord
export CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD='{"content":"🚨 Claude needs you"}'
export CLAUDE_NOTIFY_STOP_PAYLOAD='{"content":"✅ Claude finished"}'

# ntfy
export CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD='{"topic":"claude","title":"Claude","message":"Waiting for input"}'
export CLAUDE_NOTIFY_STOP_PAYLOAD='{"topic":"claude","title":"Claude","message":"Complete"}'
```

The value is POSTed as `application/json` exactly as set — no templating, no substitution.

## Requirements

`bash` and `curl`. That's it.
