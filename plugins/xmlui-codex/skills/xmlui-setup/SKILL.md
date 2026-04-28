---
name: xmlui-setup
description: Set up a complete XMLUI development environment. Use when the user wants to start XMLUI development, install the XMLUI CLI, or create a new XMLUI project.
---

# XMLUI Development Environment Setup (Codex)

Your goal is to scaffold a starter XMLUI project for the user. The XMLUI MCP server is auto-registered by the plugin's `.mcp.json` and lazy-installs the CLI on first use, so this skill no longer touches Codex MCP config.

Before running any script in this skill, resolve the absolute path to this skill directory and run scripts from there.

Select script family by OS:

- Windows PowerShell/CMD: use `.ps1` or `.cmd` scripts from `scripts/`
- macOS/Linux (Bash): use `.sh` scripts from `scripts/`

Recommended single entrypoint:

- Windows: `scripts/xmlui-setup.cmd`
- macOS/Linux: `scripts/xmlui-setup.sh`

The setup flow is not complete after CLI verification. The user must always be prompted about scaffolding the starter project. In an interactive terminal, the setup script may ask directly. In a non-interactive terminal, Codex must ask the user in chat and then rerun the setup script with the user's explicit choice.

Work through the steps below in order.

## Step 1: Preflight

Run preflight for the current OS:

- Windows: `scripts/preflight.cmd` (or `scripts/preflight.ps1`)
- macOS/Linux: `scripts/preflight.sh`

If it fails, diagnose the missing dependency and tell the user what to install.

Do not proceed until preflight passes.

## Step 2: Verify the XMLUI CLI

The XMLUI MCP server's `.mcp.json` wrapper auto-downloads the CLI to `~/.codex/plugins/data/xmlui-codex-xmlui-codex/bin/xmlui` on first MCP invocation. If the user has used any `xmlui` MCP tool already, the binary is in place.

If the binary is not yet present, install it manually:

- Windows: `scripts/install-cli.cmd` (or `scripts/install-cli.ps1`)
- macOS/Linux: `scripts/install-cli.sh`

Verify with:

```bash
~/.codex/plugins/data/xmlui-codex-xmlui-codex/bin/xmlui --help
```

If the command is still missing, stop and report the install failure.

## Step 3: Prompt for starter project scaffolding

Ask the user one question that covers both whether to scaffold and where. Do not ask separately. Recommend `~/xmlui-weather` as the default. The user can answer:

- `yes` (or anything affirmative, or just enter): scaffold at `~/xmlui-weather`
- a path: scaffold at that path
- `no`: skip scaffolding

In a non-interactive shell, do not treat the unavailable prompt as "no", and do not rerun setup with the skip flag unless the user explicitly says no. If the setup entrypoint exits with code `2` after printing the scaffold question, stop and ask the user in chat:

```text
Scaffold the XMLUI starter project at ~/xmlui-weather? Reply yes (default), no, or a custom path.
```

Then continue based on the user's answer:

- yes/default: rerun setup with the recommended path.
  - Windows: `scripts/xmlui-setup.cmd -CreateProject -ProjectName ~/xmlui-weather`
  - macOS/Linux: `scripts/xmlui-setup.sh --create-project --project-name=~/xmlui-weather`
- a custom path: rerun setup with that path.
  - Windows: `scripts/xmlui-setup.cmd -CreateProject -ProjectName <target-path>`
  - macOS/Linux: `scripts/xmlui-setup.sh --create-project --project-name=<target-path>`
- no: rerun setup with the skip-project-prompt flag to record the explicit skip and finish cleanly.
  - Windows: `scripts/xmlui-setup.cmd -SkipProjectPrompt`
  - macOS/Linux: `scripts/xmlui-setup.sh --skip-project-prompt`

Once you have the target path (resolve `~` to `$HOME` on macOS/Linux, or `%USERPROFILE%` on Windows), check whether the directory already exists:

macOS/Linux:

```bash
test -d <target-path> && echo "exists" || echo "ok"
```

Windows:

```bash
Test-Path -LiteralPath "<target-path>"
```

If it exists, tell the user and stop. Do not overwrite.

Otherwise, create the weather project at the chosen path:

```bash
~/.codex/plugins/data/xmlui-codex-xmlui-codex/bin/xmlui new xmlui-weather --output <target-path>
```

## Step 4: Tell the user how to start the dev server

Do not start the dev server from inside this skill. Codex's tool sandbox tears down child processes when the tool call ends, so a backgrounded `xmlui run` will be killed shortly after launch.

Print the exact command for the user to run in their own terminal:

```text
cd <target-path> && ~/.codex/plugins/data/xmlui-codex-xmlui-codex/bin/xmlui run
```

On Windows:

```text
cd <target-path>; & "$env:USERPROFILE\.codex\plugins\data\xmlui-codex-xmlui-codex\bin\xmlui.exe" run
```

## Final message

When complete, report:

**Your XMLUI environment is ready.** Run the dev server command above in a terminal, then see the [README](https://github.com/xmlui-org/xmlui-codex#readme) for a guided tour of the XMLUI MCP tools and the Inspector.
