# xmlui-codex Plugin

Codex plugin for XMLUI onboarding with setup scripts, MCP registration helpers, and XMLUI trace distillation support.

This is essentially the [XMLUI Claude plugin]() offered for Codex.

## What this provides

- XMLUI CLI installation flow for Windows and Bash environments
- Codex MCP server registration for XMLUI (`xmlui mcp`)
- Optional XMLUI project scaffolding (recommended default: `xmlui-weather`)
- Skills:
  - `xmlui-setup`: environment bootstrap
  - `distill-trace`: summarize XMLUI Inspector trace exports

## Folder structure

```text
xmlui-codex/
  .codex-plugin/
    plugin.json
  .mcp.json
  xmlui-setup.cmd
  xmlui-setup.sh
  skills/
    distill-trace/
      SKILL.md
    xmlui-setup/
      SKILL.md
      agents/
        openai.yaml
      scripts/
        common.sh
        preflight.sh
        install-cli.sh
        configure-mcp.sh
        dev-setup.sh
        xmlui-setup.sh
        common.ps1
        preflight.ps1
        install-cli.ps1
        configure-mcp.ps1
        dev-setup.ps1
        xmlui-setup.ps1
        preflight.cmd
        install-cli.cmd
        configure-mcp.cmd
        dev-setup.cmd
        xmlui-setup.cmd
```

## Quick start

### Windows

```bat
xmlui-setup.cmd
```

### macOS/Linux

```bash
./xmlui-setup.sh
```

## Optional project scaffolding

List templates:

```bash
xmlui list-demos
```

Create weather demo project:

```bash
xmlui new xmlui-weather --output xmlui-weather
```

Windows helper:

```bat
skills\xmlui-setup\scripts\dev-setup.cmd -Template xmlui-weather -ProjectName xmlui-weather
```

## Windows execution policy notes

If PowerShell shims are blocked, use:

- `xmlui.cmd` or `xmlui.exe`
- `codex.cmd`
- `.cmd` wrappers in this plugin

Examples:

```bat
xmlui.cmd --help
codex.cmd mcp list
codex.cmd mcp add xmlui -- xmlui.exe mcp
```

## MCP configuration

Default:

```bash
codex mcp add xmlui -- xmlui mcp
```

Windows-safe alternatives:

```bat
codex.cmd mcp add xmlui -- xmlui.exe mcp
codex.cmd mcp add xmlui -- "C:\path\to\xmlui.exe" mcp
```

Verify:

```bash
codex mcp get xmlui
```

## Trace workflow

After exporting a trace from XMLUI Inspector, ask Codex to run `distill-trace` (or ask naturally, e.g. "distill and analyze this trace"). The skill will locate the latest `xs-trace-*.json` export and summarize the user journey.

## References

- Codex MCP docs: https://developers.openai.com/codex/mcp
- Codex Skills docs: https://developers.openai.com/codex/skills
- Codex Plugin docs: https://developers.openai.com/codex/plugins/build
