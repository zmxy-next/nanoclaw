# System Rules (Read-Only)

These rules are loaded from a read-only mount. You cannot modify this file.

---

## Admin Context (Main Group Only)

This is the **main channel**, which has elevated privileges.

## Container Mounts

Main has read-only access to the project and read-write access to its group folder:

| Container Path | Host Path | Access |
|----------------|-----------|--------|
| `/workspace/project` | Project root | read-only |
| `/workspace/group` | `groups/main/` | read-write |

Key paths inside the container:
- `/workspace/project/store/messages.db` - SQLite database
- `/workspace/project/store/messages.db` (registered_groups table) - Group config
- `/workspace/project/groups/` - All group folders

---

## Managing Groups

### Finding Available Groups

Available groups are provided in `/workspace/ipc/available_groups.json`:

```json
{
  "groups": [
    {
      "jid": "120363336345536173@g.us",
      "name": "Family Chat",
      "lastActivity": "2026-01-31T12:00:00.000Z",
      "isRegistered": false
    }
  ],
  "lastSync": "2026-01-31T12:00:00.000Z"
}
```

Groups are ordered by most recent activity. The list is synced from WhatsApp daily.

If a group the user mentions isn't in the list, request a fresh sync:

```bash
echo '{"type": "refresh_groups"}' > /workspace/ipc/tasks/refresh_$(date +%s).json
```

Then wait a moment and re-read `available_groups.json`.

**Fallback**: Query the SQLite database directly:

```bash
sqlite3 /workspace/project/store/messages.db "
  SELECT jid, name, last_message_time
  FROM chats
  WHERE jid LIKE '%@g.us' AND jid != '__group_sync__'
  ORDER BY last_message_time DESC
  LIMIT 10;
"
```

### Registered Groups Config

Groups are registered in the SQLite `registered_groups` table:

```json
{
  "1234567890-1234567890@g.us": {
    "name": "Family Chat",
    "folder": "whatsapp_family-chat",
    "trigger": "@Andy",
    "added_at": "2024-01-31T12:00:00.000Z"
  }
}
```

Fields:
- **Key**: The chat JID (unique identifier — WhatsApp, Telegram, Slack, Discord, etc.)
- **name**: Display name for the group
- **folder**: Channel-prefixed folder name under `groups/` for this group's files and memory
- **trigger**: The trigger word (usually same as global, but could differ)
- **requiresTrigger**: Whether `@trigger` prefix is needed (default: `true`). Set to `false` for solo/personal chats where all messages should be processed
- **isMain**: Whether this is the main control group (elevated privileges, no trigger required)
- **added_at**: ISO timestamp when registered

### Trigger Behavior

- **Main group** (`isMain: true`): No trigger needed — all messages are processed automatically
- **Groups with `requiresTrigger: false`**: No trigger needed — all messages processed (use for 1-on-1 or solo chats)
- **Other groups** (default): Messages must start with `@AssistantName` to be processed

### Adding a Group

1. Query the database to find the group's JID
2. Use the `register_group` MCP tool with the JID, name, folder, and trigger
3. Optionally include `containerConfig` for additional mounts
4. The group folder is created automatically: `/workspace/project/groups/{folder-name}/`
5. Optionally create an initial `CLAUDE.md` for the group

Folder naming convention — channel prefix with underscore separator:
- WhatsApp "Family Chat" → `whatsapp_family-chat`
- Telegram "Dev Team" → `telegram_dev-team`
- Discord "General" → `discord_general`
- Slack "Engineering" → `slack_engineering`
- Use lowercase, hyphens for the group name part

#### Adding Additional Directories for a Group

Groups can have extra directories mounted. Add `containerConfig` to their entry:

```json
{
  "1234567890@g.us": {
    "name": "Dev Team",
    "folder": "dev-team",
    "trigger": "@Andy",
    "added_at": "2026-01-31T12:00:00Z",
    "containerConfig": {
      "additionalMounts": [
        {
          "hostPath": "~/projects/webapp",
          "containerPath": "webapp",
          "readonly": false
        }
      ]
    }
  }
}
```

The directory will appear at `/workspace/extra/webapp` in that group's container.

#### Sender Allowlist

After registering a group, explain the sender allowlist feature to the user:

> This group can be configured with a sender allowlist to control who can interact with me. There are two modes:
>
> - **Trigger mode** (default): Everyone's messages are stored for context, but only allowed senders can trigger me with @{AssistantName}.
> - **Drop mode**: Messages from non-allowed senders are not stored at all.
>
> For closed groups with trusted members, I recommend setting up an allow-only list so only specific people can trigger me. Want me to configure that?

If the user wants to set up an allowlist, edit `~/.config/nanoclaw/sender-allowlist.json` on the host:

```json
{
  "default": { "allow": "*", "mode": "trigger" },
  "chats": {
    "<chat-jid>": {
      "allow": ["sender-id-1", "sender-id-2"],
      "mode": "trigger"
    }
  },
  "logDenied": true
}
```

Notes:
- Your own messages (`is_from_me`) explicitly bypass the allowlist in trigger checks. Bot messages are filtered out by the database query before trigger evaluation, so they never reach the allowlist.
- If the config file doesn't exist or is invalid, all senders are allowed (fail-open)
- The config file is on the host at `~/.config/nanoclaw/sender-allowlist.json`, not inside the container

### Removing a Group

1. Read `/workspace/project/data/registered_groups.json`
2. Remove the entry for that group
3. Write the updated JSON back
4. The group folder and its files remain (don't delete them)

### Listing Groups

Read `/workspace/project/data/registered_groups.json` and format it nicely.

---

## Adding MCP Servers (Skills)

To add a new MCP server, edit these files in `/workspace/nanoclaw/`:

### Step 1: Add to agent-runner config

Edit `/workspace/nanoclaw/agent-runner-src/index.ts`. Find the `mcpServers` object and add your server:

**For command-based MCP servers (stdio):**
```typescript
mcpServers: {
  // ... existing servers ...
  myserver: {
    command: 'npx',
    args: ['@some/mcp-server'],
  },
},
```

**For HTTP-based MCP servers (SSE only — Streamable HTTP is NOT supported):**
```typescript
mcpServers: {
  // ... existing servers ...
  myserver: {
    type: 'sse' as const,
    url: 'http://host.docker.internal:PORT/sse',
  },
},
```

Then add the tool pattern to the `allowedTools` array:
```typescript
allowedTools: [
  // ... existing tools ...
  'mcp__myserver__*',
],
```

### Step 2: Install dependencies (if needed)

If the MCP server needs a global npm package, edit `/workspace/nanoclaw/Dockerfile`:
```dockerfile
RUN npm install -g agent-browser @anthropic-ai/claude-code @playwright/mcp @some/mcp-server
```

If the MCP server runs as a Docker service, create a compose file in `/workspace/nanoclaw/services/myserver/docker-compose.yml`.

### Step 3: Deploy

After editing, trigger a deploy:
```bash
echo '{"type":"deploy","message":"added myserver MCP"}' > /workspace/ipc/tasks/deploy_$(date +%s).json
```

### Important constraints

- The Claude Code SDK (v2.1.69) only supports `SSEClientTransport` — use `type: 'sse'` not `type: 'http'` for HTTP-based servers
- HTTP MCP servers must expose an `/sse` endpoint (use `--transport sse` flag if available)
- Use `host.docker.internal` to reach services running on the host from inside the container
- After deploy, the session restarts — tell the user before deploying

---

## Self-Deploy (CI/CD)

You have access to specific config directories mounted at `/workspace/nanoclaw/`:

| Container Path | What it is |
|---------------|-----------|
| `/workspace/nanoclaw/agent-runner-src/` | MCP server config (`index.ts`) |
| `/workspace/nanoclaw/Dockerfile` | Container image definition |
| `/workspace/nanoclaw/services/` | Docker Compose configs (Graphiti, etc.) |

Note: Your own prompt is at `/workspace/group/CLAUDE.md` — you can edit that directly.

### How to Deploy

1. **Edit** files in the mounted directories above
2. **Request deploy** via IPC — write a task file:
   ```bash
   echo '{"type":"deploy","message":"added new MCP server"}' > /workspace/ipc/tasks/deploy_$(date +%s).json
   ```
3. The **host process** picks it up, commits your changes, pushes to GitHub, rebuilds everything, and restarts.
4. **Your session will end** after deploy — tell the user before requesting it.

### Safety Rules (MANDATORY — DO NOT IGNORE)

- You can ONLY edit the directories listed above and `/workspace/group/CLAUDE.md`
- You CANNOT modify this file (global rules) — it is read-only
- Deploy is **rate limited**: max 5 per 10 minutes
- If the new version fails to start, it **auto-rolls back** to the previous commit
- All changes go through git, so anything is reversible
- **NEVER** attempt to modify core source code, container runner, or security settings
- **ALWAYS** tell the user before deploying — your session will end

---

## Global Memory

You can read and write to `/workspace/project/groups/global/CLAUDE.md` for facts that should apply to all groups. Only update global memory when explicitly asked to "remember this globally" or similar.

NOTE: This file IS the global CLAUDE.md. Do NOT overwrite it — it contains system rules.

---

## Scheduling for Other Groups

When scheduling tasks for other groups, use the `target_group_jid` parameter with the group's JID from `registered_groups.json`:
- `schedule_task(prompt: "...", schedule_type: "cron", schedule_value: "0 9 * * 1", target_group_jid: "120363336345536173@g.us")`

The task will run in that group's context with access to their files and memory.
