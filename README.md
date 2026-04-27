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

Three environment variables are required:

| Variable | Required | Description |
|---|---|---|
| `CLAUDE_NOTIFY_WEBHOOK_URL` | yes | Webhook URL. |
| `CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD` | yes | JSON body for `Notification` and `PreToolUse:ExitPlanMode`. POSTed verbatim. |
| `CLAUDE_NOTIFY_STOP_PAYLOAD` | yes | JSON body for `Stop`. POSTed verbatim. |

If any of these variables is missing, the hook exits non-zero and prints an error to stderr. Disable the plugin with `/plugin disable` if you want to silence it temporarily.

Pick one of:

### Option A — guided setup via skill

After installing the plugin, ask Claude:

```
configure notify plugin
```

This invokes the bundled `configure` skill, which inspects your existing config (shell rc files + `~/.claude/settings.json`), asks where to write the vars, generates payloads for Slack / Discord / ntfy / custom shapes, and writes them for you.

### Option B — set them manually

Export them in `~/.zshrc`, `~/.bashrc`, or add them under `env` in `~/.claude/settings.json`. See [Payload examples](#payload-examples) below.

After either option, restart Claude Code so the hook subprocess inherits the new env.

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
