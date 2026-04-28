# Fresh start

These instructions are for testing `xmlui-codex` from a genuinely clean Codex
state, not just re-adding the marketplace.

They assume:

- Codex is already installed
- you have access to the `codex` CLI
- the plugin repo is published at `xmlui-org/xmlui-codex`

## Quick command

You can preview the reset without changing anything:

```bash
./xmlui-reset.sh
```

To actually perform the plugin-level reset:

```bash
./xmlui-reset.sh --apply
```

To also wipe Codex history/session state:

```bash
./xmlui-reset.sh --apply --nuclear
```

To also remove the scaffolded starter project:

```bash
./xmlui-reset.sh --apply --remove-project
```

## What must be cleared

For a plugin-level reset, remove all four persistence points:

1. marketplace registration in `~/.codex/config.toml`
2. plugin enabled state in `~/.codex/config.toml`
3. marketplace checkout in `~/.codex/.tmp/marketplaces/xmlui-codex/`
4. plugin cache and plugin-managed data under `~/.codex/plugins/`

If you only remove the marketplace checkout, Codex can still remember that
`xmlui-codex` was enabled.

If you want a true amnesia reset, there is also historical Codex state under
`~/.codex/` that can mention prior XMLUI sessions even after the plugin is gone.
That historical state is covered in Step 9.

## 1. Quit Codex completely

Before cleaning state, quit every running Codex session.

Why this matters:

- a live session can keep plugin state in memory
- Codex may rewrite config on exit
- `/plugins` discovery is session-scoped

## 2. Remove the marketplace registration

If you previously added the XMLUI marketplace, remove it:

```bash
codex plugin marketplace remove xmlui-codex
```

This removes the `[marketplaces.xmlui-codex]` block from
`~/.codex/config.toml`.

## 3. Remove the plugin enabled-state block

Codex currently persists plugin enablement separately from marketplace
registration. Remove this block from `~/.codex/config.toml` if it exists:

```toml
[plugins."xmlui-codex@xmlui-codex"]
enabled = true
```

Quick check:

```bash
rg -n '^\[plugins\."xmlui-codex@xmlui-codex"\]|^enabled = ' ~/.codex/config.toml
```

If the block is present, edit `~/.codex/config.toml` and delete it before
restarting Codex.

## 4. Delete the cached marketplace checkout

Codex caches the added marketplace as a Git checkout under
`~/.codex/.tmp/marketplaces/`.

Delete the XMLUI marketplace cache:

```bash
rm -rf ~/.codex/.tmp/marketplaces/xmlui-codex
```

Optional verification:

```bash
test -d ~/.codex/.tmp/marketplaces/xmlui-codex && echo "still present" || echo "removed"
```

## 5. Delete the plugin cache

Codex also caches installed plugin payloads separately from the marketplace
checkout.

Delete the XMLUI plugin cache:

```bash
rm -rf ~/.codex/plugins/cache/xmlui-codex
```

Optional verification:

```bash
test -d ~/.codex/plugins/cache/xmlui-codex && echo "still present" || echo "removed"
```

## 6. Delete plugin-managed XMLUI data

The setup flow installs the XMLUI CLI into a plugin-owned data directory:

```bash
rm -rf ~/.codex/plugins/data/xmlui-codex
```

This removes the plugin-managed binary at:

```text
~/.codex/plugins/data/xmlui-codex/bin/xmlui
```

Optional verification:

```bash
test -d ~/.codex/plugins/data/xmlui-codex && echo "still present" || echo "removed"
```

## 7. Remove the plugin-managed MCP server only if this plugin created it

The setup flow may also register an `xmlui` MCP server. Check it:

```bash
codex mcp get xmlui
```

If the `command:` points at the plugin-managed path
`~/.codex/plugins/data/xmlui-codex/bin/xmlui`, remove it:

```bash
codex mcp remove xmlui
```

If your `xmlui` MCP server points somewhere else, such as a separately managed
`/usr/local/bin/xmlui`, leave it alone — that is not plugin state. But if that
`command:` no longer exists on disk, remove the entry: a stale path will fail
MCP startup and the setup skill will preserve a broken entry by default.

## 8. Optional: remove the starter project

If you also want to re-test scaffolding from scratch, remove the generated app:

```bash
rm -rf ~/xmlui-weather
```

Skip this if you want to preserve the project and only reset Codex/plugin state.

## 9. Optional: wipe Codex history and session state too

This is the nuclear option. It is not required to unload the plugin, but it is
the only way to remove prior XMLUI traces from Codex's local history/state.

Remove these if you want a genuinely fresh Codex profile:

```bash
rm -f ~/.codex/history.jsonl
rm -rf ~/.codex/sessions
rm -rf ~/.codex/shell_snapshots
rm -f ~/.codex/state_5.sqlite ~/.codex/state_5.sqlite-shm ~/.codex/state_5.sqlite-wal
rm -f ~/.codex/logs_2.sqlite ~/.codex/logs_2.sqlite-shm ~/.codex/logs_2.sqlite-wal
```

Use this only if you are intentionally discarding local Codex history.

## 10. Verify that the reset is complete

Before re-adding the marketplace, these checks should all come back clean:

```bash
rg -n '^\[marketplaces\.xmlui-codex\]|^\[plugins\."xmlui-codex@xmlui-codex"\]' ~/.codex/config.toml
test -d ~/.codex/.tmp/marketplaces/xmlui-codex && echo "marketplace cache still present" || echo "marketplace cache removed"
test -d ~/.codex/plugins/cache/xmlui-codex && echo "plugin cache still present" || echo "plugin cache removed"
test -d ~/.codex/plugins/data/xmlui-codex && echo "plugin data still present" || echo "plugin data removed"
```

Expected result:

- `rg` prints nothing
- all three directory checks print `removed`

If you also ran Step 9, these should be absent too:

```bash
test -f ~/.codex/history.jsonl && echo "history still present" || echo "history removed"
test -d ~/.codex/sessions && echo "sessions still present" || echo "sessions removed"
test -f ~/.codex/state_5.sqlite && echo "state db still present" || echo "state db removed"
test -f ~/.codex/logs_2.sqlite && echo "logs db still present" || echo "logs db removed"
```

## 11. Add the marketplace again

```bash
codex plugin marketplace add xmlui-org/xmlui-codex
```

Expected output should mention:

- marketplace name: `xmlui-codex`
- source: `https://github.com/xmlui-org/xmlui-codex.git`
- installed marketplace root: `~/.codex/.tmp/marketplaces/xmlui-codex`

## 12. Restart Codex so `/plugins` sees the marketplace

Start a fresh Codex session now.

If you added the marketplace from a prior live session and did not restart,
`/plugins` will not reflect the new marketplace correctly.

## 13. Install or enable the plugin

Open the plugin browser:

```text
/plugins
```

Then:

1. Type `xmlui-codex` to filter the list.
2. Select `xmlui-codex` in the `XMLUI for Codex` marketplace.
3. Press `Space` to install or enable it.
4. Leave the plugin browser.

Codex does not currently expose a direct `codex plugin install ...` or
`codex plugin uninstall ...` CLI command, so this step is done in the UI.

## 14. Restart Codex again

Quit Codex and start a new session after enabling the plugin.

This restart is required. It ensures the plugin skills and MCP metadata are
loaded into the new session.

## 15. Run the setup skill

Use the plugin in chat, not from the plugin browser.

To access the plugin explicitly:

```text
/skills
```

or press `$` in chat to open the picker directly.

Look for `xmlui-codex`. When you activate it, Codex will tell you the plugin is
available in the session and prompt you for the XMLUI task.

The plugin declares an `xmlui` MCP server, but the setup flow is what installs
the CLI and registers a runnable `xmlui` server for this machine.

Examples:

```text
set up XMLUI for this machine
```

or:

```text
install XMLUI and configure the MCP server
```

The setup flow should:

1. run preflight checks
2. install the XMLUI CLI if needed into `~/.codex/plugins/data/xmlui-codex/bin/`
3. register the XMLUI MCP server with Codex
4. ask whether to scaffold the starter project
5. optionally start the dev server

If `xmlui` is already installed and the `xmlui` MCP server is already
configured, the setup run may still stop after verification and ask for the
starter-project choice. That is expected. Codex must get an explicit yes/no
answer before scaffolding `xmlui-weather`.

Recommended first-run choice:

- say yes to scaffolding `xmlui-weather`
- use the default target `~/xmlui-weather`
- approve a rerun outside the sandbox if the template download needs network access

After setup succeeds, the expected next flow is:

1. open the weather app
2. export a trace from XMLUI Inspector
3. ask Codex to `distill and analyze the trace`
4. continue with natural-language app changes such as layout fixes or adding the three-city hourly tables

## Notes

- The current Codex CLI has marketplace commands: `add`, `remove`, and `upgrade`.
- It does not currently expose plugin install or uninstall as a CLI command.
- The plugin browser is for install/enable only. Actual use happens in chat.
- The large `/plugins` list is normal; filter by typing `xmlui-codex`.
- If Codex is already running when you add the marketplace, expect two restarts total: one after add, one after enable.
- If the marketplace is added before Codex launches, only the post-enable restart is needed.

## Paths involved

| What | Where |
|------|-------|
| Marketplace registration | `~/.codex/config.toml` |
| Plugin enabled-state block | `~/.codex/config.toml` |
| Cached marketplace checkout | `~/.codex/.tmp/marketplaces/xmlui-codex/` |
| Plugin cache | `~/.codex/plugins/cache/xmlui-codex/` |
| Published plugin inside the checkout | `~/.codex/.tmp/marketplaces/xmlui-codex/plugins/xmlui-codex/` |
| Plugin-managed CLI binary | `~/.codex/plugins/data/xmlui-codex/bin/xmlui` |
| Plugin-managed data root | `~/.codex/plugins/data/xmlui-codex/` |
| Local conversation history | `~/.codex/history.jsonl` |
| Local session snapshots | `~/.codex/sessions/` |
| Local state database | `~/.codex/state_5.sqlite*` |
| Local log database | `~/.codex/logs_2.sqlite*` |
