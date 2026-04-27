---
name: configure
description: Configure claude-code-notify-plugin by setting CLAUDE_NOTIFY_WEBHOOK_URL, CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD, and CLAUDE_NOTIFY_STOP_PAYLOAD. Use when the user asks to set up, configure, or change webhook/payload settings for claude-code-notify-plugin (e.g. "configure notify plugin", "set up Slack notifications for Claude", "change my notify webhook URL", "switch payload to Discord").
---

# Configure claude-code-notify-plugin

Walk the user through setting the three required env vars and write them to a single location. Do not invent values — confirm each one with the user before writing.

## Required env vars

| Variable | Purpose |
|---|---|
| `CLAUDE_NOTIFY_WEBHOOK_URL` | Webhook endpoint (POST target). |
| `CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD` | JSON body for Notification + ExitPlanMode events. |
| `CLAUDE_NOTIFY_STOP_PAYLOAD` | JSON body for Stop events. |

All three are mandatory — the hooks exit non-zero if any is unset.

## Steps

1. **Check for existing config first.** Before asking anything, inspect each likely location and report back what's already set. Don't overwrite without telling the user what you found.

   Check (in this order, since later ones override earlier ones at runtime):
   - `~/.zshrc`, `~/.bashrc`, `~/.bash_profile`, `~/.profile` — grep for `CLAUDE_NOTIFY_`
   - `~/.claude/settings.json` — `.env` object
   - `./.claude/settings.json` and `./.claude/settings.local.json` (project-scoped) — `.env` object
   - Current shell env (`echo "$CLAUDE_NOTIFY_WEBHOOK_URL"` etc.) — note that this only reflects what your shell exports, not what Claude Code's hook subprocess will see

   Use `Read` for the JSON files and `Bash` with `grep -H CLAUDE_NOTIFY_ ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile 2>/dev/null` for shell rc files. Run these in parallel.

   Summarize findings to the user before proceeding. For each of the three vars, report: which files set it, and (for non-secret-looking values) the current value. **Mask `CLAUDE_NOTIFY_WEBHOOK_URL`** — show only the host + first/last few chars (e.g. `https://hooks.slack.com/triggers/T01…/abc`), never the full token.

   Then ask the user what they want to do:
   - **Nothing missing, all looks right** → confirm and stop. Don't rewrite for cosmetics.
   - **Update one specific var** → skip to step 4 with just that var.
   - **Reconfigure from scratch** → continue to step 2.
   - **Resolve a conflict** (same var set in multiple places) → ask which location should be the source of truth, then offer to remove the duplicates.

2. **Pick a destination.** Ask which webhook the user wants to target. Common shapes (use as starting points, edit per the user's actual webhook):

   - **Slack workflow trigger**
     ```json
     {"origin":"🌰 Devbox","message":"🚨 Waiting for input"}
     {"origin":"🌰 Devbox","message":"✅ Complete"}
     ```
   - **Discord webhook**
     ```json
     {"content":"🚨 Claude needs you"}
     {"content":"✅ Claude finished"}
     ```
   - **ntfy**
     ```json
     {"topic":"claude","title":"Claude","message":"Waiting for input"}
     {"topic":"claude","title":"Claude","message":"Complete"}
     ```
   - **Custom** — ask the user for the exact JSON shape their webhook expects. Payload is POSTed verbatim with `Content-Type: application/json`; no templating.

3. **Get the webhook URL.** Ask the user. Don't paste it into chat output afterwards if it looks like a secret token.

4. **Pick where to write the vars.** Ask the user which they want — don't assume:

   - **`~/.claude/settings.json` `env`** (recommended): scoped to Claude Code only, doesn't leak into other shells. Use the `update-config` skill to merge keys into the `env` object — do not overwrite existing keys.
   - **`~/.zshrc` / `~/.bashrc`**: applies to every shell. Append `export FOO='...'` lines. Use single quotes around the JSON so `$` and `"` survive.
   - **Project `.claude/settings.json` `env`**: only for this repo.

   Default to wherever existing vars already live (from step 1) so the user ends up with a single source of truth.

5. **Write the values.** Use the appropriate tool:
   - `settings.json` → `Edit` (or the `update-config` skill if available) to merge into the `env` object.
   - Shell rc → `Edit` to append the three `export` lines under a clear comment like `# claude-code-notify-plugin`.

6. **Tell the user how to activate.**
   - `settings.json` changes: restart Claude Code.
   - Shell rc changes: `source ~/.zshrc` (or open a new terminal) **and** restart Claude Code so the hook subprocess inherits the new env.

7. **Offer a quick test.** Suggest running:
   ```bash
   curl -sS -H "Content-Type: application/json" \
     -d "$CLAUDE_NOTIFY_NOTIFICATION_PAYLOAD" \
     "$CLAUDE_NOTIFY_WEBHOOK_URL"
   ```
   to confirm the webhook accepts the payload before relying on Claude to trigger it.

## Notes

- Payloads are POSTed exactly as set — no variable substitution, no `{{event}}` templating. If the user wants dynamic content, they need a webhook that enriches the payload itself.
- To silence the plugin temporarily without unsetting vars: `/plugin disable claude-code-notify-plugin`.
- If the user only wants to change one of the three vars, edit just that one — don't rewrite the others.
