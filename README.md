# XMLUI Quickstart

Get a running XMLUI app, an AI assistant that knows the XMLUI docs, and a built-in Inspector for debugging in under 5 minutes.

## Prerequisites

Codex

## Add a marketplace

```bash
codex plugin marketplace add xmlui-org/xmlui-codex
```

If Codex is already running when you add the marketplace, restart Codex once so `/plugins` can see `XMLUI for Codex`.

## Install the XMLUI plugin

```text
/plugins
```

Type `xmlui-codex` to filter the list, open `xmlui-codex` from `XMLUI for Codex`, and press `Space` to install or enable it.

What you should see before install:

- `xmlui-codex · Can be installed · xmlui-codex`
- `Install plugin`
- skills `xmlui-codex:distill-trace` and `xmlui-codex:xmlui-setup`
- MCP server `xmlui`

**Restart Codex now.** This restart is required after enabling the plugin so its skills and MCP metadata load into the new session.

Restart summary:

- If you added the marketplace while Codex was already open, there are two restarts total: one after `codex plugin marketplace add ...`, and one after enabling `xmlui-codex` in `/plugins`.
- If you added the marketplace before launching Codex, this post-install restart is the only restart you need.

## Set up

Open the skill picker, activate `xmlui-codex`, then ask for setup:

```text
/skills
```

or press `$` in chat and choose `xmlui-codex`.

Then say:

```text
Set up XMLUI for this machine
```

This downloads the XMLUI CLI if needed, configures the `xmlui` MCP server if needed, creates the `xmlui-weather` app in a directory you choose, and starts the dev server.

If `xmlui` and the `xmlui` MCP server are already installed, setup can still stop and ask whether it should scaffold `xmlui-weather`. That prompt is expected. The recommended default is `~/xmlui-weather`.

If template download needs network access, Codex may ask to rerun setup outside the sandbox.

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
