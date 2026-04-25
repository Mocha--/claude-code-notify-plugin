#!/bin/bash
if [ -z "$CLAUDE_NOTIFY_WEBHOOK_URL" ]; then
  echo "claude-code-notify-plugin: CLAUDE_NOTIFY_WEBHOOK_URL is not set. Set it to your webhook URL." >&2
  exit 1
fi
if [ -z "$CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD" ]; then
  echo "claude-code-notify-plugin: CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD is not set. Set it to a JSON string to use as the webhook body." >&2
  exit 1
fi
curl -sS -m 5 \
  -H "Content-Type: application/json" \
  -d "$CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD" \
  "$CLAUDE_NOTIFY_WEBHOOK_URL" >/dev/null 2>&1
exit 0
