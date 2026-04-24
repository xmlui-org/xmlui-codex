# xmlui-codex Plugin

Codex plugin for XMLUI onboarding with setup scripts, MCP registration helpers, and XMLUI trace distillation support.

This is essentially the [XMLUI Claude plugin](https://github.com/xmlui-org/xmlui-claude) offered for Codex.

## Prerequisites

[Codex](https://developers.openai.com/codex) with plugin support.

## Install the plugin

This repository provides a local Codex plugin with XMLUI skills and MCP registration metadata.

The plugin includes:

- XMLUI CLI installation flow for Windows and Bash environments
- Codex MCP server registration for XMLUI (`xmlui mcp`)
- Optional XMLUI project scaffolding (recommended default: `xmlui-weather`)
- Skills:
  - `xmlui-setup`: environment bootstrap
  - `distill-trace`: summarize XMLUI Inspector trace exports

## Set up

Run the setup script for your platform.

### Windows

```bat
xmlui-setup.cmd
```

### macOS/Linux

```bash
./xmlui-setup.sh
```

The setup flow installs the XMLUI CLI if needed, registers the XMLUI MCP server with Codex, and can scaffold a starter project.
Choose explicitly whether to scaffold an XMLUI project (default template/path: `xmlui-weather` at `~/xmlui-weather`).

## Explore the MCP tools

The plugin registers the XMLUI MCP server so Codex can use the XMLUI documentation and tooling through MCP.

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

Examples:

```bat
xmlui.cmd --help
codex.cmd mcp list
codex.cmd mcp add xmlui -- xmlui.exe mcp
```

## Use the Inspector

The plugin includes the `distill-trace` skill for XMLUI Inspector trace exports.

### Run the app

If you want a sample project to inspect, list the available demos:

```bash
xmlui list-demos
```

Create the weather demo project:

```bash
xmlui new xmlui-weather --output xmlui-weather
```

Windows helper:

```bat
skills\xmlui-setup\scripts\dev-setup.cmd -Template xmlui-weather -ProjectName xmlui-weather
```

After exporting a trace from XMLUI Inspector, ask Codex to run `distill-trace`, or ask naturally, for example: "distill and analyze this trace".

## Modify the layout

Once the demo app is running, use Codex with the XMLUI MCP server to answer XMLUI-specific UI questions and make evidence-based layout changes.

Examples:

- How do I paginate a list or table?
- How do I handle errors in a DataSource?
- What layout components are available?

## Add a feature

Use the scaffolded project and XMLUI MCP tools to iterate on larger changes. If something goes wrong, export an Inspector trace and ask Codex to analyze it with `distill-trace`.

## References

- Codex MCP docs: https://developers.openai.com/codex/mcp
- Codex Skills docs: https://developers.openai.com/codex/skills
- Codex Plugin docs: https://developers.openai.com/codex/plugins/build
