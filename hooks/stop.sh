#!/bin/bash
[ -z "$CLAUDE_NOTIFY_WEBHOOK_URL" ] && exit 0
ORIGIN="${CLAUDE_NOTIFY_ORIGIN:-Claude Code}"
curl -sS -m 5 \
  -H "Content-Type: application/json" \
  -d "{\"origin\": \"${ORIGIN}\", \"message\": \"✅ Complete\"}" \
  "$CLAUDE_NOTIFY_WEBHOOK_URL" >/dev/null 2>&1
exit 0
