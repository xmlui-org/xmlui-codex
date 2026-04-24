---
name: distill-trace
description: Analyze or distill an XMLUI Inspector trace. Use when the user says "analyze the trace", "distill the trace", "what happened in the trace", or wants to understand an exported trace file.
---

# Distill an XMLUI Inspector Trace

The user has exported a trace JSON file from the XMLUI Inspector. Distill the raw log events into a concise step-by-step summary of what happened.

First, call the XMLUI trace-locator MCP tool (`xmlui_find_trace`, typically exposed as `mcp__xmlui__xmlui_find_trace`) to locate the most recent trace export. Then read that file and summarize:

- startup actions
- user interactions
- API calls
- state/value changes
- navigation
- toasts/errors
- notable form data

Focus on the user journey and outcomes, not framework internals.

Rules:

- Ignore `component:vars:init` events.
- Ignore events with traceId `unknown`.
- Group events by `traceId`.
- Sort by `perfTs` (fallback to `ts`).
- Collapse repetitive textbox keydown events into a single "fill" step when possible.
- Deduplicate click+click+dblclick sequences to just the dblclick.
- Highlight failures prominently (API errors, error toasts, validation failures).
- Summarize API results briefly, do not dump raw payloads.

Output format:

1. Numbered steps in time order.
2. For each step, include:
   - what the user did
   - what happened (API, state, UI effects)
   - notable details (navigation, submitted data, errors)
