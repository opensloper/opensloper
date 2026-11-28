---
description: "Ask Claude, Anthropic's AI model, to draft or change the open sewing pattern in your own words."
---

# Asking Claude

The **Claude** tab in the side panel, its icon a speech bubble with a
question mark, lets you ask Claude, Anthropic's AI model,
to work on the pattern you have open, in your own words:

- "Add 2 cm ease at the hip."
- "Why is point C invalid?"
- "Move the shoulder dart to the side seam."
- "Make the selected curve meet the waist at a right angle."

Claude reads the pattern, makes the changes with the same operations you use,
and says what it changed. Each change appears on the canvas at once and is one
step on the undo history, labelled *Claude*, such as **Edit → Undo Claude: Add
variable**, so you can look at what it did and undo any of it.

## Setting it up

Claude needs an Anthropic API key, which you get from the
[Claude Console](https://platform.claude.com). Requests are billed to that key's
account.

1. Choose **Assistance → Anthropic API Key…** (the General tab of
   **Edit → Preferences**) and paste the key into **Anthropic API key**. It is
   kept in a file of its own that only you can read, not in the settings file.
   The publish and drape apps' Claude tabs use the same key, so you set it
   once, in any of the apps.
   If the `ANTHROPIC_API_KEY` environment variable is set, that key is used
   instead. Until there is a key, the Claude tab's question box and buttons
   are off, and **Assistance → Ask Claude** with them.
2. Choose **Assistance → Ask Claude**, or open the **Claude** tab, type your
   question and press ++enter++ (++shift+enter++ starts a new line), or click
   **Ask**.

Other AI assistants can work on the pattern too, through MCP, with
**Assistance → Allow Assistants to Connect** (see
[Scripting](../scripting/index.md#an-assistant-in-the-design-window)).

The publish and drape apps have a Claude tab of their own, which arranges the
layout or places the pieces on the body (see
[Arrange pieces](../publish/arrange.md#asking-claude) and
[Draping](../drape/index.md#asking-claude)).

### If it cannot connect

Run `opensloper-cli check-connection` (in the downloads it is beside the apps;
on macOS in `OpenSloper.app/Contents/MacOS`). It says whether OpenSSL loads,
which certificates it trusts and whether the API answers; it sends no key.

- **Linux** uses the system's OpenSSL 3 (`libssl3`, which most systems have).
- **Windows and macOS** downloads bring their own OpenSSL 3 and trust the root
  certificates in `data/cacert.pem`, not the system's. If your network checks
  HTTPS through a proxy with a certificate of its own, set the `SSL_CERT_FILE`
  environment variable to a file with that certificate, or try it with
  `check-connection --ca-file=FILE`.

## Working with it

- Claude can see what you have selected and which part of the draft is in
  view, so "this point" and "the curve I selected" work. It can also look at
  the draft as a picture to check the shape of what it made.
- **Stop** ends the answer in progress; changes already made stay, each one
  undoable.
- **New Conversation** starts afresh. Claude remembers the conversation until
  then, so you can say "now do the same on the back".
- Claude does not open other patterns, and saves only when you ask. It asks
  before writing a file outside the pattern's folder. While you are dragging,
  it waits.

## Privacy

Everything you make stays on your computer, except what Claude reads to
answer you. Your questions, and the parts of the pattern Claude reads (names,
formulas, values, notes and, when it looks, a picture of the draft), are sent
to Anthropic. Text in a pattern someone else made is treated as data, not as
instructions to Claude.

Nothing that could put a name to the measurements is sent:

- **No folders.** The pattern is named by its file name alone, such as
  `bodice.sloper`, never the folder it is in.
- **No measurement file name.** Claude is told only that there is a
  measurement file, never what it is called, so a file named after the person
  measured does not give them away.

The measurement values themselves are sent when Claude asks for them, so it
can say which measurement a problem comes from or add a missing one. To keep
them back, turn off **Let AI assistants read the measurements** in the General tab of
**Edit → Preferences**. Claude then cannot read or change them, though it still
sees the pattern's points and lengths, which are worked out from them. The
setting applies to any AI assistant connected to the window too (see
[Privacy](../scripting/index.md#privacy) under Scripting). The Claude tab says
which way it is set before you ask your first question.

What you type into the pattern is sent as written, so keep people's names out
of a pattern Claude will read: in notes, piece and variable names, and the
descriptions in the measurement file.

To have Claude work on the pattern from Claude Code or Claude Desktop instead,
see [An assistant in the design window](../scripting/index.md#an-assistant-in-the-design-window).
