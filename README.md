# XMLUI Quickstart

Get a running XMLUI app, an AI assistant that knows the XMLUI docs, and a built-in Inspector for debugging in under 5 minutes.

## Prerequisites

Codex. Install from the [Codex CLI docs](https://developers.openai.com/codex/cli) (or `npm i -g @openai/codex` / `brew install --cask codex`). Source: [openai/codex](https://github.com/openai/codex).

**Quit any running Codex sessions before you start.** This guide assumes Codex is not running when you add the marketplace, which keeps the restart count predictable: one restart total, after enabling the plugin.

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

Type `xmlui-codex` to filter the list, open `xmlui-codex`, select `Install plugin`.

**Restart Codex now.** This restart is required after enabling the plugin so its skills and MCP server load into the new session. This is the only restart you need — the `xmlui` MCP server is registered automatically by the plugin's `.mcp.json` and lazy-installs the XMLUI CLI on first use.

After restarting, type `$xmlui` in chat to confirm the plugin is loaded. You should see:

```
xmlui-codex                  [Plugin] XMLUI development environment setup for Codex
XMLUI Setup                  [Skill] Scaffold an XMLUI starter project
distill-trace (xmlui-codex)  [Skill] Analyze or distill an XMLUI Inspector trace. Use 
```

## Set up

Again start Codex, then type this at the Codex prompt (not your OS shell):

```text
/skills
```

Choose `XMLUI Setup`.

The setup skill scaffolds the `xmlui-weather` app in a directory you choose (the recommended default is `~/xmlui-weather`). It does not start the dev server, register MCP, or add `xmlui` to your shell PATH — the plugin's `.mcp.json` already registered the MCP server when you enabled the plugin.

If template download needs network access, Codex may ask to rerun setup outside the sandbox.

When setup finishes, it will print the exact command to run the dev server. **Run that command yourself in a separate terminal.** Codex's tool sandbox tears down child processes after a tool call, so a backgrounded `xmlui run` from inside the skill would die immediately.

To verify the MCP tools are live, ask Codex "What XMLUI MCP tools are available?" — it should enumerate the live tool list.

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
