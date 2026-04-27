# xmlui-codex

Codex plugin for XMLUI onboarding with setup scripts, MCP registration helpers, and XMLUI trace distillation support.

This repo is meant to work like `xmlui-claude`: users should add the repo as a marketplace source in Codex. Manual cloning is for local development only.

## Install in Codex

1. Add the marketplace from the published repo:

```bash
codex plugin marketplace add xmlui-org/xmlui-codex
```

2. Restart Codex if it is already running.

Why this restart matters:

- If you added the marketplace from a live Codex session, restart once now so `/plugins` can see the new `XMLUI for Codex` marketplace.
- If Codex was not running when you added the marketplace, there is nothing to restart yet.

3. Open the plugin browser explicitly:

```text
/plugins
```

4. Type `xmlui-codex` to filter the list instead of scrolling the full marketplace.

5. Open `xmlui-codex` from the `XMLUI for Codex` marketplace.

What you should see before install:

- The plugin details page shows `xmlui-codex · Can be installed · xmlui-codex`.
- The menu includes `Install plugin`.
- The details mention skills `xmlui-codex:distill-trace` and `xmlui-codex:xmlui-setup`.
- The details mention MCP server `xmlui`.

6. Install or enable the plugin.

What you should see after install:

- The `/plugins` list shows `xmlui-codex` as `Installed`.
- The selected row shows `Space to disable; Enter view details.`

7. Exit the plugin browser and restart Codex after enabling the plugin.

Why this restart matters:

- This restart is required. It loads the plugin skills and MCP metadata into the new session.

Restart summary:

- If you add the marketplace while Codex is already open, expect two restarts total:
  - one after `codex plugin marketplace add ...`
  - one after enabling `xmlui-codex` in `/plugins`
- If you add the marketplace before launching Codex, only the post-enable restart is needed.

Use the plain repo command above. Do not sparse-checkout only `.agents/plugins`, because this marketplace resolves the plugin from `./plugins/xmlui-codex`.

The plugin includes:

- XMLUI CLI installation flow for Windows and Bash environments
- Codex MCP server registration for XMLUI (`xmlui mcp`)
- Optional XMLUI project scaffolding
- Skills:
  - `xmlui-setup`: environment bootstrap
  - `distill-trace`: summarize XMLUI Inspector trace exports

## Run setup

The plugin browser is only for install/enable. After the plugin is installed, use it in chat.

There is no Claude-style `/xmlui:xmlui-setup` slash command in Codex.

To access the plugin in Codex:

```text
/skills
```

or press `$` in chat to open the picker directly.

Look for `xmlui-codex`. When you activate it, Codex shows that the plugin is available in the session and asks what XMLUI task you want to do.

At that point, ask for setup in plain English:

- "Set up XMLUI for this machine"
- "Install XMLUI and configure the MCP server"

You can also ask Codex to run `xmlui-setup`, but the normal UX is to ask for the task in natural language after activating `xmlui-codex`.

The setup flow installs the XMLUI CLI if needed, registers the XMLUI MCP server with Codex, and can scaffold a starter project.

What to expect during setup:

- If `xmlui` is already installed and the `xmlui` MCP server is already configured, the setup run may still stop and ask for an explicit starter-project decision.
- This is expected. The setup contract requires Codex to ask whether it should scaffold the `xmlui-weather` starter project instead of assuming yes or no.
- The recommended default path is `~/xmlui-weather`, but you can also choose the current directory or provide a custom path.
- If you do not want a starter app, tell Codex to skip starter-project scaffolding.
- If scaffolding needs to download the `xmlui-weather` template, Codex may need approval to rerun the setup outside the sandbox so network access is available.
- On success, the setup flow scaffolds `~/xmlui-weather` and starts `xmlui run`.

## End-to-End Flow

This is the tested `xmlui-claude`-style path in Codex:

1. Add the marketplace with `codex plugin marketplace add xmlui-org/xmlui-codex`.
2. Restart Codex only if it was already running.
3. Open `/plugins`, filter to `xmlui-codex`, and install it from `XMLUI for Codex`.
4. Restart Codex after enabling the plugin.
5. Open `/skills` or press `$`, activate `xmlui-codex`, and ask:

```text
Set up XMLUI for this machine
```

6. Let setup finish preflight, CLI install checks, and MCP registration.
7. When setup asks about scaffolding, accept the recommended path `~/xmlui-weather` unless you want a different target.
8. Let setup create `xmlui-weather` and start `xmlui run`.
9. Use the weather app, open XMLUI Inspector, export a trace, and then ask:

```text
distill and analyze the trace
```

10. After the trace summary, continue with natural-language editing requests such as:

- `center the input box and button as group, and center the radio group on a new row`
- `add three tables that report hourly temperatures for three user-specifiable cities`

## Explore the MCP tools

Default registration:

```bash
codex mcp add xmlui -- xmlui mcp
```

Windows-safe alternatives:

```bat
codex.cmd mcp add xmlui -- xmlui.exe mcp
codex.cmd mcp add xmlui -- "C:\path\to\xmlui.exe" mcp
```

Verify the server configuration:

```bash
codex mcp get xmlui
```

If PowerShell shims are blocked on Windows, use `xmlui.cmd`, `xmlui.exe`, `codex.cmd`, or the `.cmd` wrappers in this plugin.

## Use the Inspector

The plugin includes the `distill-trace` skill for XMLUI Inspector trace exports.

If you want a sample project to inspect:

```bash
xmlui list-demos
xmlui new xmlui-weather --output xmlui-weather
```

To find it in the skill picker, look for `distill-trace (xmlui-codex)`.

After exporting a trace from XMLUI Inspector, ask Codex to run `distill-trace`, or ask naturally, for example: "distill and analyze this trace".

## Local development

You do not need to clone this repo to use the plugin. Clone it only if you are developing or testing the plugin itself.

From a local checkout, use the repo-root wrapper:

```bash
bash ./xmlui-setup.sh
```

On Windows:

```bat
xmlui-setup.cmd
```

or the plugin entrypoint directly:

```bash
bash ./plugins/xmlui-codex/xmlui-setup.sh
```

Windows plugin entrypoint:

```bat
plugins\xmlui-codex\xmlui-setup.cmd
```

Using `bash ...` avoids needing executable bits on nested scripts.

## References

- Codex plugin docs: https://developers.openai.com/codex/plugins/build
- Codex skills docs: https://developers.openai.com/codex/skills
- Codex MCP docs: https://developers.openai.com/codex/mcp
