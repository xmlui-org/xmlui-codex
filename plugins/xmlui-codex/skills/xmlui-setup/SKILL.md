---
name: xmlui-setup
description: Set up a complete XMLUI development environment. Use when the user wants to start XMLUI development, install the XMLUI CLI, configure the XMLUI MCP server for Codex, or create a new XMLUI project.
---

# XMLUI Development Environment Setup (Codex)

Your goal is to set up a complete XMLUI development environment for the user.

Before running any script in this skill, resolve the absolute path to this skill directory and run scripts from there.

Select script family by OS:

- Windows PowerShell/CMD: use `.ps1` or `.cmd` scripts from `scripts/`
- macOS/Linux (Bash): use `.sh` scripts from `scripts/`

Recommended single entrypoint:

- Windows: `scripts/xmlui-setup.cmd`
- macOS/Linux: `scripts/xmlui-setup.sh`

The setup flow is not complete after MCP configuration. After the XMLUI MCP
server is configured, the user must always be prompted about scaffolding the
starter project. In an interactive terminal, the setup script may ask directly.
In a non-interactive terminal, Codex must ask the user in chat and then rerun the
setup script with the user's explicit choice.

Work through the steps below in order.

## Step 1: Preflight

Run preflight for the current OS:

- Windows: `scripts/preflight.cmd` (or `scripts/preflight.ps1`)
- macOS/Linux: `scripts/preflight.sh`

If it fails, diagnose the missing dependency and tell the user what to install.

Do not proceed until preflight passes.

## Step 2: Install the XMLUI CLI

Check whether `xmlui` is already available on PATH.

- If installed, skip to Step 3.
- If missing, run install script for the current OS:
  - Windows: `scripts/install-cli.cmd` (or `scripts/install-cli.ps1`)
  - macOS/Linux: `scripts/install-cli.sh`

On Windows, if `xmlui` points to a blocked PowerShell shim, use `xmlui.exe` or `xmlui.cmd` for verification.

After installation, verify with:

```bash
xmlui --help
```

If the command is still missing, stop and report the install failure.

## Step 3: Configure XMLUI MCP for Codex

First check current MCP servers:

```bash
codex mcp list
```

If `xmlui` is already configured, skip to Step 4.

If not configured, add it:

```bash
codex mcp add xmlui -- xmlui mcp
```

If that fails on Windows, retry with:

```bash
codex mcp add xmlui -- xmlui.exe mcp
```

If `codex` is blocked by execution policy on Windows, use:

```bash
codex.cmd mcp list
codex.cmd mcp add xmlui -- xmlui.exe mcp
```

Verify:

```bash
codex mcp get xmlui
```

## Step 4: Prompt for starter project scaffolding

After MCP configuration, ask the user whether they want to scaffold a starter
project. Use "yes" as the default recommendation.

If yes, ask the user where to create the project. Offer `~/xmlui-weather` as the recommended default (template: `xmlui-weather`), and the current directory as an alternative. The user can also enter a custom path.

If no, skip Step 4 and Step 5.

In a non-interactive shell, do not treat the unavailable prompt as "no", and do
not rerun setup with the skip flag unless the user explicitly says no. If the
setup entrypoint exits with code `2` after printing the scaffold question, stop
and ask the user in chat:

```text
Do you want to scaffold the XMLUI starter project? The recommended default is yes, at ~/xmlui-weather. You can also choose the current directory or provide a custom path.
```

Then continue based on the user's answer:

- If yes/default: rerun setup with the create-project flag and selected path.
  - Windows: `scripts/xmlui-setup.cmd -CreateProject -ProjectName <target-path>`
  - macOS/Linux: `scripts/xmlui-setup.sh --create-project --project-name=<target-path>`
- If no: rerun setup with the skip-project-prompt flag only to record the
  explicit skip and finish cleanly.
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
xmlui new xmlui-weather --output <target-path>
```

Windows helper script:

```bash
scripts/dev-setup.cmd -Template xmlui-weather -ProjectName <target-path>
```

Remember the chosen path. You will need it in Step 5.

## Step 5: Start the dev server

After scaffolding succeeds, start the app:

```bash
cd <target-path> && xmlui run
```

The dev server should open the app in the default browser.

## Final message

When complete, report:

**Your XMLUI environment is ready.** See the [README](https://github.com/xmlui-org/xmlui-codex#readme) for a guided tour of the XMLUI MCP tools and the Inspector.
