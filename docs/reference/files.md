---
description: "OpenSloper's file formats: patterns, measurement files, layouts and drapes as JSON, each with a JSON Schema and an example."
---

# File formats

!!! note

    This page is generated from the program by `opensloper-cli doc files`; do not edit it by hand.

The apps keep their files as JSON text, so other programs, scripts and assistants such as Claude can read and write them. Each kind of file is described here, and by a JSON Schema that a validator can check a file against.

## Rules for every file

- The file is UTF-8 JSON with one object at the top. Its `format` says what kind of file it is and its `version` which version of that format; a program refuses a file newer than it knows.
- Lengths in measurement and layout files are millimetres. A pattern's formulas are in the pattern's own `units`; a number may also carry its unit, as `2in`.
- Objects have IDs, whole numbers above 0 that never change and are never reused. Other objects and formulas refer to them by ID: a member such as `base` holds the number, and formula text writes it in braces, `{12}`. Names are for people: letters, digits and underscore, not starting with a digit.
- File names inside a file are relative to that file's folder unless absolute, and written with `/`.
- The apps write every member in a fixed order, two spaces to a level, with numbers in the shortest form that reads back exactly and `.` as the decimal point, so files compare well in version control.
- Members marked required must be there for the file to load. Others may be left out of a file written by hand, and take their defaults. A file that does not load says why, and nothing of it is used.
- The schemas list exactly the members the apps write. The apps also read a few members older files have, which the schemas leave out.
- Every file has a `version`. The apps read a file of any version from 1 up to the one they write, bringing an older file up to date as they load it, and save it at the current version; they refuse a file newer than they know, made by a later release.

## Pattern (`.sloper`)

Made by opensloper-design. It holds the definitions only: the formula for each point and line, and which edges make each piece. Positions are worked out again every time it opens.

Version 1. JSON Schema, for files of this version: [pattern.schema.json](schemas/pattern.schema.json).

| Member | Value | Required | Description |
| --- | --- | --- | --- |
| `format` | one of: `pattern` | yes | What the file is; a file with another value does not load |
| `version` | whole number | yes | The version of the format, from 1. The apps read every older version and always write the current one; they refuse a file newer than they know |
| `units` | one of: `mm`, `cm`, `in` |  | The unit of the numbers in formulas |
| `notes` | text |  | Notes about the pattern |
| `measurementFile` | text |  | The measurement file last used with it, relative to the pattern's folder unless absolute, with / between folders; empty when there is none |
| `identity` | text |  | Tells the pattern from others when objects are pasted; made when the pattern is |
| `nextId` | whole number |  | The next ID to hand out, above every ID in the file, so deleted IDs are never reused; when left out, one above the highest ID |
| `variables` | list |  | The # variables, in the order they were made |
| `variables[].id` | whole number | yes | The variable's ID; IDs are unique across variables, materials and objects |
| `variables[].name` | text | yes | The name formulas use after # |
| `variables[].formula` | formula | yes | Its value, in ID form: another object is written {12} |
| `variables[].description` | text |  | What it is for |
| `objects[]` | list, each object |  | The points, edges, transforms, pieces, seams and notes, in the order they were made, each after every object it uses; their members are on the Operations and objects page |
| `materials` | list |  | The materials pieces are cut from; left out while the only one is the untouched Main |
| `materials[].id` | whole number | yes | The material's ID |
| `materials[].name` | text | yes | Its name, unique in the pattern |
| `materials[].color` | text | yes | Its colour, as #RRGGBB |
| `materials[].fill` | one of: `tint`, `hatch` |  | How its pieces are filled on screen and in print |
| `materials[].allowance` | number |  | The seam allowance of its pieces, in the pattern's unit, when it has its own |
| `materials[].width` | number |  | How wide it is, in the pattern's unit; a width alone is a roll. Pieces wider are problems |
| `materials[].length` | number |  | How long a sheet of it is, in the pattern's unit, with a width; left out for a roll |
| `materials[].allowTurns` | true or false |  | Whether pieces may lie a quarter turn round on it, for material with no grain |
| `materials[].fabric` | one of: `cotton`, `silk`, `jersey`, `wool`, `denim`, `canvas`, `leather` |  | How it drapes in Blender, from the drape app; left out, it drapes as cotton |
| `view` | group |  | How the design app last showed the pattern; not part of undo |
| `view.zoom` | number |  | The zoom |
| `view.centre[]` | list, each number |  | The point in the middle of the window, as x and y in mm |
| `view.hiddenRoles[]` | list, each one of: `construction`, `outline`, `placement`, `stitch`, `fold`, `cut`, `skive`, `edgeFinish` |  | The kinds of line hidden on the canvas |
| `view.hideAnnotations` | true or false |  | Whether notes are hidden |
| `view.hiddenPieces[]` | list, each whole number |  | Pieces hidden on the canvas, by ID, with what only they use; they still print |
| `view.isolate` | whole number |  | The piece worked on alone on the canvas, by ID; everything it does not use is dimmed |
| `view.pieceOrder[]` | list, each whole number |  | Pieces in drawing order on the canvas, lowest first, by ID; a piece not listed goes on top |

Each entry in `objects` is an object whose members depend on its `type`; they are listed on [Operations and objects](operations.md).

### Example

```json
{
  "format": "pattern",
  "version": 1,
  "units": "cm",
  "notes": "",
  "measurementFile": "bill.slm",
  "nextId": 6,
  "variables": [
    {
      "id": 1,
      "name": "ease",
      "formula": "2",
      "description": "Ease at the waist"
    }
  ],
  "objects": [
    {
      "id": 2,
      "type": "freePoint",
      "name": "A",
      "x": "0",
      "y": "0"
    },
    {
      "id": 3,
      "type": "offsetPoint",
      "name": "B",
      "base": 2,
      "mode": "polar",
      "length": "@waist / 4 + {1}",
      "angle": "0"
    },
    {
      "id": 4,
      "type": "line",
      "start": 2,
      "end": 3,
      "role": "outline"
    }
  ],
  "materials": [
    {
      "id": 5,
      "name": "Main",
      "color": "#5B8DB8",
      "fill": "tint",
      "allowance": 1.5
    }
  ]
}
```

## Measurements (`.slm`)

Made by opensloper-measurements: one person's measurements, with a value each, or a size table, with a value for each size. Patterns refer to a measurement by its key, as @waist.

Version 1. JSON Schema, for files of this version: [measurements.schema.json](schemas/measurements.schema.json).

| Member | Value | Required | Description |
| --- | --- | --- | --- |
| `format` | one of: `measurements` | yes | What the file is; a file with another value does not load |
| `version` | whole number | yes | The version of the format, from 1. The apps read every older version and always write the current one; they refuse a file newer than they know |
| `units` | one of: `mm` |  | Always mm: values in this file are millimetres |
| `name` | text |  | Whose measurements, or the name of the size table |
| `notes` | text |  | Notes, such as how they were taken |
| `sizes[]` | list, each text |  | A size table's sizes, as named; left out for one person's set |
| `measurements` | list | yes | The measurements, in the order shown |
| `measurements[].key` | text | yes | The name patterns use after @; letters, digits and underscore |
| `measurements[].value` | number |  | The value, in a set with no sizes |
| `measurements[].values[]` | list, each number or null |  | In a size table, one value for each size in order; null for a size with no value |
| `measurements[].description` | text |  | What is measured |

### Example

```json
{
  "format": "measurements",
  "version": 1,
  "units": "mm",
  "name": "Block sizes",
  "notes": "",
  "sizes": [
    "36",
    "38"
  ],
  "measurements": [
    {
      "key": "waist",
      "values": [
        700,
        740
      ],
      "description": "Waist circumference"
    },
    {
      "key": "back_length",
      "values": [
        405,
        null
      ],
      "description": "Nape to waist"
    }
  ]
}
```

## Layout (`.slayout`)

Made by opensloper-publish: where the pieces of one or more patterns go on the pages, roll or material, and how they print. Positions are plain numbers in mm, from the top left, y down.

Version 1. JSON Schema, for files of this version: [layout.schema.json](schemas/layout.schema.json).

| Member | Value | Required | Description |
| --- | --- | --- | --- |
| `format` | one of: `layout` | yes | What the file is; a file with another value does not load |
| `version` | whole number | yes | The version of the format, from 1. The apps read every older version and always write the current one; they refuse a file newer than they know |
| `units` | one of: `mm` |  | Always mm: values in this file are millimetres |
| `name` | text |  | The layout's name, for the title block |
| `nextId` | whole number |  | The next source ID to hand out |
| `sources` | list | yes | The patterns laid out, each with the measurements to draw it with |
| `sources[].id` | whole number | yes | The source's ID, which placements refer to |
| `sources[].pattern` | text | yes | The pattern file, relative to the layout's folder |
| `sources[].measurementFile` | text |  | The measurement file, relative to the layout's folder; the pattern's own when left out |
| `sources[].size` | text |  | The size, for a size table; its first size when left out |
| `output` | group |  | What the layout prints on and how |
| `output.kind` | one of: `tiled`, `large`, `projector`, `material` |  | tiled: pages taped together; large: a roll; projector: shown on the material; material: a sheet of material for a cutting machine |
| `output.rollWidth` | number |  | The roll's width, for large |
| `output.paper` | text |  | The paper size, A4, A3 or Letter, or a name of your own with its width and height |
| `output.paperWidth` | number |  | The paper's width, for a size of your own |
| `output.paperHeight` | number |  | The paper's height, for a size of your own |
| `output.margin` | number |  | The edge of the paper left blank |
| `output.overlap` | number |  | How far tiles overlap |
| `output.marks` | one of: `diamond`, `none`, `halfCircle` |  | The marks for lining up tiles |
| `output.fill` | one of: `none`, `tint`, `hatch` |  | How pieces are filled; none when left out |
| `output.profile` | text |  | The cutting machine profile, from the settings |
| `output.outputProfile` | text |  | The output profile, from the settings, which chooses what prints |
| `output.materialWidth` | number |  | The material's width, for material |
| `output.materialLength` | number |  | The material's length, for material; 0 or left out for as long as needed |
| `output.allowTurns` | true or false |  | Whether a piece may lie across the grain, for material |
| `output.material` | text |  | Only pieces cut from this material, by name |
| `output.excludedPages[]` | list, each text |  | Pages left out of the print, by their captions |
| `placements` | list |  | Where each copy of each piece lies |
| `placements[].source` | whole number | yes | The source the piece is from |
| `placements[].piece` | whole number | yes | The piece's ID in that source's pattern |
| `placements[].copy` | whole number |  | Which copy, from 1, for a piece cut more than once |
| `placements[].x` | number | yes | The left of the piece's cutting line, after turning and flipping |
| `placements[].y` | number | yes | The top of the piece's cutting line, after turning and flipping |
| `placements[].rotation` | whole number |  | The turn in degrees, a multiple of 90, anticlockwise |
| `placements[].flipped` | true or false |  | Whether the piece is flipped over, before it is turned |
| `sheetNotes` | list |  | Text placed on the sheet, not on a piece |
| `sheetNotes[].text` | text | yes | The text; it may hold fields such as {date} |
| `sheetNotes[].x` | number | yes | Its left |
| `sheetNotes[].y` | number | yes | Its top |
| `sheetNotes[].size` | number |  | Its size in points |
| `sheetNotes[].align` | one of: `left`, `centre`, `right` |  | How its lines line up |
| `sheetNotes[].box` | true or false |  | Whether it has a white box behind it |
| `sheetNotes[].font` | text |  | The font family it prints in; left out for the default sans-serif |
| `sheetNotes[].bold` | true or false |  | Whether it is bold |
| `sheetNotes[].italic` | true or false |  | Whether it is italic |
| `titleBlock` | group |  | The title block; no title block when left out |
| `titleBlock.corner` | one of: `bottomRight`, `bottomLeft`, `topRight` |  | The corner of the page it sits in |
| `titleBlock.fields[]` | list, each one of: `pattern.name`, `measurements.name`, `layout.name`, `date`, `cutlist`, `materials`, `materialneeded` |  | What it shows, in order |
| `titleBlock.everyPage` | true or false |  | Whether it is on every page, not only the first |

### Example

```json
{
  "format": "layout",
  "version": 1,
  "units": "mm",
  "name": "Skirt, A4",
  "nextId": 2,
  "sources": [
    {
      "id": 1,
      "pattern": "skirt.sloper",
      "measurementFile": "sizes.slm",
      "size": "38"
    }
  ],
  "output": {
    "kind": "tiled",
    "rollWidth": 914,
    "paper": "A4",
    "margin": 6,
    "overlap": 10,
    "marks": "diamond"
  },
  "placements": [
    {
      "source": 1,
      "piece": 42,
      "copy": 1,
      "x": 20,
      "y": 20,
      "rotation": 0,
      "flipped": false
    }
  ],
  "titleBlock": {
    "corner": "bottomRight",
    "fields": [
      "pattern.name",
      "measurements.name",
      "date"
    ],
    "everyPage": false
  }
}
```

## Drape (`.sdrape`)

Made by opensloper-drape: the pieces of one or more patterns placed round a body in 3D, for draping in Blender. Positions are in mm: x to the body's left, y towards its back, z up, the body facing -y with its feet at z = 0.

Version 1. JSON Schema, for files of this version: [drape.schema.json](schemas/drape.schema.json).

| Member | Value | Required | Description |
| --- | --- | --- | --- |
| `format` | one of: `drape` | yes | What the file is; a file with another value does not load |
| `version` | whole number | yes | The version of the format, from 1. The apps read every older version and always write the current one; they refuse a file newer than they know |
| `units` | one of: `mm` |  | Always mm: values in this file are millimetres |
| `name` | text |  | The drape's name |
| `nextId` | whole number |  | The next source ID to hand out |
| `sources` | list | yes | The patterns placed, each with the measurements to draw it with |
| `sources[].id` | whole number | yes | The source's ID, which placements refer to |
| `sources[].pattern` | text | yes | The pattern file, relative to the layout's folder |
| `sources[].measurementFile` | text |  | The measurement file, relative to the layout's folder; the pattern's own when left out |
| `sources[].size` | text |  | The size, for a size table; its first size when left out |
| `body` | group |  | The body the pieces are placed on |
| `body.kind` | one of: `measurements`, `none` | yes | measurements: a generic body built from a measurement set; none: no body, for accessories |
| `body.measurementFile` | text |  | The body's measurement file, relative to the drape file's folder; the first source's when left out |
| `body.size` | text |  | The body's size, for a size table; the first source's when left out |
| `body.arms` | true or false |  | Whether the figure has its arms, true when left out; false leaves them and the hands out, so a full skirt does not catch on them |
| `gap` | number |  | How far pieces are placed off the body and apart across a seam |
| `placements` | list |  | Where each copy of each piece is placed; a copy not listed is left out |
| `placements[].source` | whole number | yes | The source the piece is from |
| `placements[].piece` | whole number | yes | The piece's ID in that source's pattern |
| `placements[].copy` | whole number |  | Which copy, from 1, for a piece cut more than once |
| `placements[].position[]` | list, each number | yes | Where the piece's anchor goes: x, y and z. The anchor is the middle of its grainline, else the middle of its seam line's extent |
| `placements[].rotation[]` | list, each number | yes | The turns in degrees about x, then y, then z, anticlockwise looking from the positive end of each axis: Blender's XYZ Euler angles. Unturned, a piece stands upright facing -y, as drawn |
| `placements[].attached[]` | list, each whole number |  | The IDs of the piece's edges held to the body in Blender, as a waist or a strap's end, or held where they are placed when there is no body |

### Example

```json
{
  "format": "drape",
  "version": 1,
  "units": "mm",
  "name": "Skirt",
  "nextId": 2,
  "sources": [
    {
      "id": 1,
      "pattern": "skirt.sloper",
      "measurementFile": "sizes.slm",
      "size": "38"
    }
  ],
  "body": {
    "kind": "measurements"
  },
  "gap": 20,
  "placements": [
    {
      "source": 1,
      "piece": 42,
      "copy": 1,
      "position": [
        0,
        -170,
        900
      ],
      "rotation": [
        0,
        0,
        0
      ],
      "attached": [
        12
      ]
    }
  ]
}
```

## Blender scene (`.blender.json`)

Written by opensloper-cli drape from a drape file, for Blender's cloth simulation, and never read back. Its meshes are OBJ files beside it, in mm with the drape's axes: the pieces', each in its own frame with its anchor at the origin and the right side of the fabric facing -y, and the body's, as placed. Vertices are counted from 0 within each object, in the order the OBJ file lists them.

Version 1. JSON Schema, for files of this version: [blender.schema.json](schemas/blender.schema.json).

| Member | Value | Required | Description |
| --- | --- | --- | --- |
| `format` | one of: `blender` | yes | What the file is; a file with another value does not load |
| `version` | whole number | yes | The version of the format, from 1 |
| `units` | one of: `mm` | yes | Always mm: values in this file are millimetres |
| `name` | text |  | The drape's name |
| `pieces` | text | yes | The pieces' OBJ file, relative to this file's folder: one object for each entry of objects, in the same order and with the same names |
| `body` | text |  | The body's OBJ file, relative to this file's folder; left out when the drape has no body |
| `spacing` | number | yes | About how far apart the meshes' points are |
| `objects` | list | yes | Every placed copy of a piece that could be meshed |
| `objects[].name` | text | yes | Its object's name in the OBJ file: the pattern file's name, the piece's and the copy |
| `objects[].source` | whole number | yes | The drape file's source the piece is from |
| `objects[].piece` | whole number | yes | The piece's ID in its pattern |
| `objects[].copy` | whole number | yes | Which copy of the piece, from 1 |
| `objects[].mirrored` | true or false | yes | Whether the copy is cut mirrored, as the left of a pair; its mesh is mirrored already |
| `objects[].material` | text |  | The name of the material it is cut from; left out when it has none |
| `objects[].fabric` | one of: `cotton`, `silk`, `jersey`, `wool`, `denim`, `canvas`, `leather` |  | The fabric of its material, which sets how it drapes; left out, it drapes as cotton |
| `objects[].color` | text | yes | The colour to show it in, as #RRGGBB |
| `objects[].vertices` | whole number | yes | How many vertices its mesh has |
| `objects[].position[]` | list, each number | yes | Where its origin goes: the object's location |
| `objects[].rotation[]` | list, each number | yes | Its turns in degrees, in Blender's XYZ Euler order: the object's rotation_euler |
| `objects[].attached[]` | list, each whole number |  | Its vertices held to the body, or where they are placed when there is no body: those of its attached edges, from 0 |
| `seams` | list | yes | The seams between placed copies, each with the vertices it sews together |
| `seams[].source` | whole number | yes | The source the seam is from |
| `seams[].seam` | whole number | yes | The seam's ID in its pattern |
| `seams[].name` | text |  | The seam's name |
| `seams[].pairs` | list | yes | Pairs of vertices to sew together, each an object (its place in objects, from 0) and a vertex of it |
| `seams[].pairs[].first` | whole number | yes | The first vertex's object, from 0 |
| `seams[].pairs[].firstVertex` | whole number | yes | The first vertex, from 0 |
| `seams[].pairs[].second` | whole number | yes | The second vertex's object, from 0 |
| `seams[].pairs[].secondVertex` | whole number | yes | The second vertex, from 0 |

### Example

```json
{
  "format": "blender",
  "version": 1,
  "units": "mm",
  "name": "Skirt",
  "pieces": "skirt.pieces.obj",
  "body": "skirt.body.obj",
  "spacing": 10,
  "objects": [
    {
      "name": "skirt Front 1",
      "source": 1,
      "piece": 42,
      "copy": 1,
      "mirrored": false,
      "material": "Main",
      "fabric": "cotton",
      "color": "#5B8DB8",
      "vertices": 412,
      "position": [
        0,
        -170,
        900
      ],
      "rotation": [
        0,
        0,
        0
      ],
      "attached": [
        0,
        1,
        2
      ]
    }
  ],
  "seams": [
    {
      "source": 1,
      "seam": 57,
      "name": "Side",
      "pairs": [
        {
          "first": 0,
          "firstVertex": 12,
          "second": 1,
          "secondVertex": 40
        }
      ]
    }
  ]
}
```

