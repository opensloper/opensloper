---
description: "opensloper-cli commands and options: export patterns to PDF, SVG and DXF, lay them out, check them and run the API from scripts."
---

# Command line

!!! note

    This page is generated from the program by `opensloper-cli doc cli`; do not edit it by hand.

`opensloper-cli` exports and checks patterns without a window, for scripts and builds.

```
opensloper-cli [options] <command> [arguments]
```

## Commands

### check

Evaluate a pattern and report problems

```
opensloper-cli check PATTERN [-m FILE] [-s SIZE] [--json]
```

### export

Export a layout file as PDF, SVG or DXF

```
opensloper-cli export LAYOUT [-o FILE] [--format=FORMAT] [--profile=NAME]
```

### export-draft

Export a pattern's draft as SVG or a PNG image, as the drafting window shows it

```
opensloper-cli export-draft PATTERN [-o FILE] [-m FILE] [-s SIZE] [--format=FORMAT] [--width=PIXELS] [--labels] [--upto=NAME]
```

### layout

Start a layout file for a pattern, with every piece placed

```
opensloper-cli layout PATTERN [-o FILE] [-m FILE] [-s SIZE]
```

### measurements

List a measurement file, set a value, or see what a pattern needs that it lacks

```
opensloper-cli measurements list FILE [-s SIZE] [--json]
opensloper-cli measurements set FILE KEY VALUE [-s SIZE] [-d TEXT]
opensloper-cli measurements missing FILE PATTERN
```

### pack

Pack a layout's pieces and rewrite the layout file

```
opensloper-cli pack LAYOUT
```

### drape

Export a drape file for Blender's cloth simulation: the pieces' and the body's meshes as OBJ, a scene file with the placements and the vertices each seam sews, and the script that drapes them; with --run, run Blender on it

```
opensloper-cli drape DRAPE [-o FILE] [--spacing=MM] [--run] [--blender=PROGRAM] [--frames=N]
```

### materials

Estimate how much of each material a layout's patterns, or one pattern, need to cut

```
opensloper-cli materials LAYOUT|PATTERN [--json]
```

### serve

Answer JSON-RPC 2.0 on stdin and stdout, one message per line, as the Automation API and as an MCP server

```
opensloper-cli serve [--connect]
```

### check-connection

See whether the Claude assistant can reach the API: that OpenSSL loads, the server's certificate is trusted and it answers. No API key is sent.

```
opensloper-cli check-connection [--url=URL] [--ca-file=FILE]
```

### doc

Write a page of the reference documentation as Markdown, or a file format's JSON Schema; with no topic, list the topics

```
opensloper-cli doc TOPIC [-o FILE]
opensloper-cli doc
```

## Options

| Option | Value | Description |
| --- | --- | --- |
| `-h`, `--help` |  | Show this help |
| `-V`, `--version` |  | Show the version |
| `-m`, `--measurements` | file | Measurement file (.slm); default: the one the pattern names |
| `-s`, `--size` | size | check, layout: the size to use from a size table, default the first; measurements: the size to list or set |
| `-d`, `--description` | text | measurements set: the description; default: keep the one it has |
| `--json` |  | check: print every computed value as JSON; materials: print the estimate, in mm; measurements list: print the file |
| `-o`, `--output` | file | layout, export, export-draft, doc: the file to write; drape: the scene file, with the meshes written beside it |
| `--format` | format | export: pdf, svg, dxf or machine-dxf; default: the extension of --output, or pdf. export-draft: svg or png; default: the extension of --output, or svg |
| `--profile` | name | export: a machine profile from the settings, in place of the layout's |
| `--labels` |  | export-draft: name the points and pieces |
| `--upto` | name | export-draft: draw only this object and those before it, as the pattern was when it was added |
| `--width` | pixels | export-draft: the width of a png in pixels, from 16 to 4096; default: 1600 |
| `--spacing` | mm | drape: how far apart the mesh's points are, in mm; default: 10 |
| `--run` |  | drape: run Blender on the files written, which saves the draped result as NAME.blend |
| `--blender` | program | drape: the Blender program to run; default: blender on the path, or where its installer puts it |
| `--frames` | n | drape: how many frames Blender simulates; default: 120 |
| `--connect` |  | serve: work on the pattern open in the design window, which must allow assistants to connect (Assistance menu, or --automation) |
| `--url` | url | check-connection: the API to reach; default: ANTHROPIC_BASE_URL, or https://api.anthropic.com |
| `--ca-file` | file | check-connection: trust the certificates in this PEM file, in place of those OpenSloper uses |

## Arguments

After the command, in this order; each command takes the ones it needs.

| Argument | Description |
| --- | --- |
| `pattern` | Pattern file (.sloper), layout file (.slayout) to export or estimate, drape file (.sdrape) to export, for measurements: list, set or missing, or for doc: the topic |
| `file` | measurements: the measurement file (.slm) |
| `key` | measurements set: the key; measurements missing: the pattern file |
| `value` | measurements set: the value in mm |

## Exit codes

| Code | Meaning |
| --- | --- |
| 0 | Success |
| 1 | check: the pattern has problems |
| 2 | A usage error, a file that could not be read or written, check-connection: no answer, or drape --run: Blender could not be found or did not finish |
