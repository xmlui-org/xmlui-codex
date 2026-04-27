# Fresh start

These instructions are for testing `xmlui-codex` from a clean Codex state.

They assume:

- Codex is already installed
- you have access to the `codex` CLI
- the plugin repo is published at `xmlui-org/xmlui-codex`

## 1. Remove the previous marketplace

If you previously added the XMLUI marketplace, remove it first:

```bash
codex plugin marketplace remove xmlui-codex
```

This removes the marketplace registration from `~/.codex/config.toml`.

## 2. Delete the cached marketplace checkout

Codex caches the added marketplace as a Git checkout under `~/.codex/.tmp/marketplaces/`.

Delete the XMLUI marketplace cache:

```bash
rm -rf ~/.codex/.tmp/marketplaces/xmlui-codex
```

Optional verification:

```bash
test -d ~/.codex/.tmp/marketplaces/xmlui-codex && echo "still present" || echo "removed"
```

## 3. Add the marketplace again

```bash
codex plugin marketplace add xmlui-org/xmlui-codex
```

Expected output should mention:

- marketplace name: `xmlui-codex`
- source: `https://github.com/xmlui-org/xmlui-codex.git`
- installed marketplace root: `~/.codex/.tmp/marketplaces/xmlui-codex`

## 4. Restart Codex so `/plugins` sees the marketplace

If Codex is already running, quit it and start a fresh session now.

Why this restart matters:

- Marketplace discovery is session-scoped.
- If you added the marketplace from a live Codex session, the running session will not pick it up until restart.

If Codex was not running when you added the marketplace, this is just your first launch.

## 5. Install or enable the plugin

Open the plugin browser:

```text
/plugins
```

Then:

1. Type `xmlui-codex` to filter the list.
2. Select `xmlui-codex` in the `XMLUI for Codex` marketplace.
3. Press `Space` to install or enable it.
4. Leave the plugin browser.

Codex does not currently expose a direct `codex plugin install ...` CLI command, so this step is done in the UI.

## 6. Restart Codex again

Quit Codex and start a new session after enabling the plugin.

This restart is required. It ensures the plugin skills and MCP metadata are loaded into the new session.

## 7. Run the setup skill

Use the plugin in chat, not from the plugin browser.

To access the plugin explicitly:

```text
/skills
```

or press `$` in chat to open the picker directly.

Look for `xmlui-codex`. When you activate it, Codex will tell you the plugin is available in the session and prompt you for the XMLUI task.

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
2. install the XMLUI CLI if needed
3. register the XMLUI MCP server with Codex
4. ask whether to scaffold the starter project
5. optionally start the dev server

If `xmlui` is already installed and the `xmlui` MCP server is already configured, the setup run may still stop after verification and ask for the starter-project choice. That is expected. Codex must get an explicit yes/no answer before scaffolding `xmlui-weather`.

Recommended first-run choice:

- say yes to scaffolding `xmlui-weather`
- use the default target `~/xmlui-weather`
- approve a rerun outside the sandbox if the template download needs network access

After setup succeeds, the expected next flow is:

1. open the weather app
2. export a trace from XMLUI Inspector
3. ask Codex to `distill and analyze the trace`
4. continue with natural-language app changes such as layout fixes or adding the three-city hourly tables

## 8. Verify the marketplace state

You can verify the marketplace was re-added with:

```bash
codex plugin marketplace add xmlui-org/xmlui-codex
```

If it is already present, Codex will print the installed marketplace root instead of adding a duplicate.

You can also inspect the config entry:

```bash
rg -n '^\[marketplaces\.xmlui-codex\]|^source = ' ~/.codex/config.toml
```

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
| Cached marketplace checkout | `~/.codex/.tmp/marketplaces/xmlui-codex/` |
| Published plugin inside the checkout | `~/.codex/.tmp/marketplaces/xmlui-codex/plugins/xmlui-codex/` |
| Curated built-in plugin catalog | `~/.codex/.tmp/plugins/` |
