# xmlui-codex

Codex plugin for XMLUI onboarding with setup scripts, MCP registration helpers, and XMLUI trace distillation support.

This repo is meant to work like `xmlui-claude`: users should add the repo as a marketplace source in Codex. Manual cloning is for local development only.

## Install in Codex

Add the marketplace from the published repo:

```bash
codex plugin marketplace add xmlui-org/xmlui-codex
```

Then restart Codex, open the Plugin Directory, and install `xmlui-codex` from the `XMLUI for Codex` marketplace.

Use the plain repo command above. Do not sparse-checkout only `.agents/plugins`, because this marketplace resolves the plugin from `./plugins/xmlui-codex`.

The plugin includes:

- XMLUI CLI installation flow for Windows and Bash environments
- Codex MCP server registration for XMLUI (`xmlui mcp`)
- Optional XMLUI project scaffolding
- Skills:
  - `xmlui-setup`: environment bootstrap
  - `distill-trace`: summarize XMLUI Inspector trace exports

## Run setup

After the plugin is installed, ask Codex to run `xmlui-setup`, or ask naturally:

- "Set up XMLUI for this machine"
- "Install XMLUI and configure the MCP server"

The setup flow installs the XMLUI CLI if needed, registers the XMLUI MCP server with Codex, and can scaffold a starter project.

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
