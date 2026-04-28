# XMLUI Quickstart

Get a running XMLUI app, an AI assistant that knows the XMLUI docs, and a built-in Inspector for debugging in under 5 minutes.

## Prerequisites

Codex. Install from the [Codex CLI docs](https://developers.openai.com/codex/cli) (or `npm i -g @openai/codex` / `brew install --cask codex`). Source: [openai/codex](https://github.com/openai/codex).

**Quit any running Codex sessions before you start.** This guide assumes Codex is not running when you add the marketplace, which keeps the restart count predictable: two restarts total, one after enabling the plugin and one after running setup.

## Add a marketplace

Run this in your OS shell (bash, zsh, PowerShell, etc.):

```bash
codex plugin marketplace add xmlui-org/xmlui-codex
```

## Install the XMLUI plugin

Now start Codex, then type this at the Codex prompt (not your OS shell):

```text
/plugins
```

Type `xmlui-codex` to filter the list, open `xmlui-codex` from `XMLUI for Codex`, and press `Space` to install or enable it.

**Restart #1: restart Codex now.** This restart is required after enabling the plugin so its skills and MCP metadata load into the new session.

A second restart is required later, after setup runs. Codex binds MCP servers at session start and does not hot-reload them, so the `xmlui` MCP server that setup registers only becomes live in the session after that.

After restarting, type `$xmlui-codex` in chat to confirm the plugin is loaded. Codex should reply that `xmlui-codex` is available in this workspace and list the two skills:

- `xmlui-codex:xmlui-setup` for installing/configuring an XMLUI dev environment
- `xmlui-codex:distill-trace` for analyzing an exported XMLUI Inspector trace

## Set up

You verified the plugin is loaded by typing `$xmlui-codex` above. Now tell Codex what you want it to do:

```text
Set up XMLUI for this machine
```

(Alternatively, press `$` in chat to open the skill picker and select `XMLUI Setup` directly.)

This downloads the XMLUI CLI if needed into `~/.codex/plugins/data/xmlui-codex/bin/`, registers the promised `xmlui` MCP server with Codex to use that binary, creates the `xmlui-weather` app in a directory you choose, and starts the dev server. It does not add `xmlui` to your shell PATH.

Installing the plugin declares the `xmlui` MCP server in plugin metadata. Running setup is what makes that server runnable on this machine.

If `xmlui` and the `xmlui` MCP server are already installed, setup can still stop and ask whether it should scaffold `xmlui-weather`. That prompt is expected. The recommended default is `~/xmlui-weather`.

If template download needs network access, Codex may ask to rerun setup outside the sandbox.

**Restart #2: restart Codex once setup finishes.** The `xmlui` MCP server is now registered, but Codex only starts MCP servers at session boot. Without this restart, the XMLUI MCP tools will not be available even though `codex mcp get xmlui` shows the registration.

After restarting, verify by asking Codex "What XMLUI MCP tools are available?" — it should enumerate the live tool list, not just the names cached in plugin files.

## Explore the MCP tools

The plugin gives Codex access to the XMLUI documentation via MCP tools.

Ask Codex: "What XMLUI MCP tools are available to you?"

It can use these tools to answer questions like:

- How do I paginate a list or table?
- How do I handle errors in a DataSource?
- What layout components are available?

If you're writing the XMLUI code yourself, you'll search the documentation to find the answers. The MCP server helps Codex do that.

## Use the Inspector

The weather app includes the Inspector. It records traces of everything your app does, so you and Codex can see what is going on.

### Run the app

When it loads, the app makes an API call to fetch weather for Santa Rosa, CA, and displays the data. Click the Inspector and expand the Startup phase to see what happened. This is your distilled view of a much more detailed log.

Close Inspector and switch to another city. Then open Inspector again, click Export, and say to Codex: "distill and analyze the trace".

## Modify the layout

You have a running app, an AI that knows about XMLUI, and a way for you and the AI to observe the app's behavior. Try making changes. The layout isn't great, ask Codex to "center the input box and button as group, and center the radio group on a new row". Expect Codex to use the MCP tools to find an answer based on a documented how-to example that provably works. Don't be afraid to challenge Codex to prove its answer and cite evidence.

When Codex previews a plausible answer, approve it and refresh the browser. Did it work? Great! If not, capture a screenshot of the botched layout, paste it into Codex, and tell it to look harder for an evidence-based solution.

## Add a feature

Ask Codex to "add three tables that report hourly temperatures for three user-specifiable cities". If things go wrong, challenge Codex to cite evidence for its proposed solution. If Codex needs more information about what went wrong, export a trace for it to analyze.
