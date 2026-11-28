# OpenSloper coding standards

How OpenSloper's Pascal code is named, laid out and formatted, then its TypeScript, and at the end how releases are versioned. Architecture rules (layers, IDs, commands, evaluation states) are in `CLAUDE.md` and the design document.

## Formatting

Code is formatted with JEDI Code Format (JCF), the formatter built into the Lazarus IDE, using the project settings in `jcfsettings.cfg`.

- **From the command line:** `./opensloper-make.sh format` formats every source file; `./opensloper-make.sh format --check` lists files that need formatting without changing them; `./opensloper-make.sh format FILE...` formats only those files. Run it before committing.
- **In the IDE:** use the same settings, so the IDE and `opensloper-make.sh format` agree. Copy `jcfsettings.cfg` over the IDE's copy in the Lazarus configuration folder (for the fpcupdeluxe install, `~/Packages/fpc_build/config_lazarus/jcfsettings.cfg`), then use Source → JEDI Code Format → Format Current Editor Window.
- **Formatter version:** `opensloper-make.sh format` builds the command-line formatter into `lib/jcf` on first use, from the source of the Lazarus that `lazbuild` belongs to (override with `JCF_SOURCE` in `build.local.sh`). The reference is the release Lazarus that CI uses (4.8): CI fails a pull request whose files that formatter would change. Delete `lib/jcf` to rebuild it.
- **Not formatted:** `src/packages/` (third-party code) and `src/core/clipper2/osclipper2.pas`, which Lazarus regenerates.

What the settings produce:

| Rule | Setting |
| --- | --- |
| Indentation | 2 spaces, no tabs; procedure bodies not indented further |
| `begin` / `end` | On their own line, at the indentation of the statement they belong to; in a `case`, a branch's `begin` lines up with its label |
| Line length | At most 164 characters; longer lines are broken at a parameter or operator, with the continuation indented 2 more |
| Line breaks you add | Kept: the formatter does not join lines in expressions, parameter lists or `var` sections, so long string expressions and argument lists can be laid out one part per line |
| Operators | `and`, `or`, `+` and other binary operators end a broken line rather than start the next one |
| Spacing | One space around operators and `:=`, after commas and semicolons; none before `(` in calls and declarations, none inside brackets |
| Blank lines | One before each routine; at most two in a row; none at the start of `var` sections or procedure headers |
| Alignment | No column alignment of assignments, declarations or comments |
| Reserved words and directives | Lower case: `begin`, `function`, `override` |
| Built-in types | Lower case: `double`, `integer`, `boolean`, `char`, `byte`, `string` |
| Constants | `True`, `False` and `nil` keep their case |
| Program `uses` | One unit per line |

The project settings are the IDE's own settings with four changes: `RemoveExpressionReturns`, `RemoveProcedureDefReturns` and `RemoveVarReturns` are off, so deliberate line breaks survive, and `WhenRebreakLines` is 1, so lines over 164 characters are broken.

## Checking the rules

`./opensloper-make.sh check` checks the rules below that a pattern match can find: the GPL header and `{$mode ObjFPC}{$H+}`, unit and file names, the layering of `uses` clauses (no LCL below `src/ui`, and which `Sloper.*` areas each folder may use), `Sloper.Core.CodePage` first in programs, `FreeAndNil`, `Assigned`, `ssModifier` (apart from `CONTROL_KEY` in `Sloper.UI.Commands`, for the shortcuts written `Ctrl`), `SysUtils.GetEnvironmentVariable` in units that use `Windows`, and message text that should be a `resourcestring`. These are errors. Single-letter names are warnings. CI runs it on the files each pull request changes. The rest, such as descriptive names, `try`/`finally` protection and undoable commands, is left to review. A `thirdparty` folder (`src/output/thirdparty`) belongs to its parent's area and layer and meets every rule, except that it may use BGRABitmap built without the LCL (`BGRABitmap`, `BGRABitmapTypes`, `BGRASVG`).

## Naming

- **Descriptive names.** No single-letter variables or parameters: `Index`, not `I`; `Node`, not `N`; `Failure`, not `E`. A name says what the value is (`StartPos`, `LengthOrDx`, `TokenIndex`), not just its type.
  - Exceptions: the core math units (`Sloper.Core.Geometry`, `Sloper.Core.Geometry3`, `Sloper.Core.Bezier`, `Sloper.Core.Numeric`), where single letters (`P`, `T`, `A`, `B`) match the formulas and read better; and `tests/`.
- **Parameters that would clash take an `A` prefix.** When a parameter's plain name matches a field, property or method of the class (`AName`, `AEdge`, `AKey`, `AValue`), prefix it with `A`. Free Pascal refuses a local or parameter with the same name as a member. Locals use plain descriptive names instead (`EdgeObject`, `PointPos`).
- **Fields** start with `F` and are private; expose them through properties.
- **Types** start with `T`, exception classes with `E`; enumeration values carry a short lower-case prefix (`esValid`, `omPolar`, `pdAngle`).
- **Units** are named `Sloper.<Area>.<Name>`, where the area is the folder: `Sloper.Core.Formula` (`src/core`), `Sloper.Document.…` (`src/document`), `Sloper.Editor.Snap` (`src/editor`), `Sloper.UI.Canvas` (`src/ui`), `Sloper.Design.MainForm` (`src/design`), `Sloper.Output.…` (`src/output`, and `src/output/thirdparty`, which takes its parent's area) and `Sloper.Tests.Pattern` (`tests`). File names are the unit name in lower case (`sloper.core.formula.pas`).
- **Constants** are upper case with underscores between words (`COPY_LINK_WIDTH`, `DIAMOND_SCALE`).
- **Resource strings** start with `rs` and the unit's area (`rsFormulaEmpty`, `rsDraftPastEnd`).
- **IDs and names** follow the project's name rules (see `CLAUDE.md`): letters, digits and underscore, compared without regard to case.

## Other conventions

- Every unit starts with the GPLv3 header from `documents/gpl-header.txt`, then a short comment saying what the unit is for.
- Units start with `{$mode ObjFPC}{$H+}`.
- Comments explain why, or what is not obvious; they don't restate the code.
- Constants are private to their unit: declare them in the `const` section after `implementation`, not inside a routine, so the values a unit is tuned by are in one place. Make one public in the interface only when another unit uses it, tests included. A constant inside a routine has a name only that routine needs to understand (`NAMES`, `TOLERANCE`), so give it a name that is clear in the whole unit when moving it out (`TRANSFORM_TYPE_NAMES`, `CHAIN_TOLERANCE`).
- No bare numbers for fixed values such as sizes, widths, tolerances, counts and limits: give each a named constant, with a comment giving its unit where it has one (`COPY_LINK_WIDTH = 1.5`, in pixels). Plain arithmetic is exempt: `0` and `1` as starting values or steps, and halving with `/ 2`. Colours keep their red, green and blue numbers together where the colour is defined (`BGRA(37, 116, 214)`).
- Collections use `Generics.Collections`: `specialize TObjectList<T>` for lists that own their items, `specialize TDictionary<string, T>` for lookups by key, instead of `TList` with casts. Declare the specialization as a named type (`TDraftObjectList = specialize TObjectList<TDraftObject>`). Removing from an owning list frees the item; use `ExtractIndex` to take one out without freeing it.
- Free objects with `FreeAndNil(Obj)`, never `Obj.Free` or `Obj.Destroy`, so a reference is either `nil` or a live instance (see [Modern Object Pascal](https://castle-engine.io/modern_pascal)). It does not clear other copies of the reference. The one exception is an indexed or typecast item (`TObject(List[Index]).Free`, `Controls[0].Free`), which cannot be passed to `FreeAndNil`; clear the list straight after, or let its owner drop it.
- Test a reference with `Assigned(Obj)` or `not Assigned(Obj)`, never `Obj <> nil` or `Obj = nil`. This applies to objects, pointers and event handlers alike. For a dynamic array, test `Length(Items) = 0`. Clearing a reference is still `Obj := nil`.
- Protect every object a routine creates, so an exception or an early `Exit` cannot leak it. Heaptrc only sees the paths the tests run, so don't rely on an object being safe because nothing "should" raise; a failure halfway through building a result leaked 79 blocks before this rule was followed.
  - **A local object:** create it just before the `try`, not inside it, and free it in the `finally`. If `Create` raises inside the `try`, the `finally` runs on a variable that was never assigned. `Exit` inside the `try` still runs the `finally`.

    ```pascal
    Pattern := TPattern.Create;
    try
      // use it
    finally
      FreeAndNil(Pattern);
    end;
    ```

  - **Several objects:** set them all to `nil`, then create them inside one `try`, instead of nesting a `try` for each. This relies on `FreeAndNil` being safe on `nil`.
  - **Handing an object over:** when another object takes ownership, set your variable to `nil` straight after, so the `finally` does not free it twice.
  - **A function returning a new object:** `finally` would free what is being returned, so use `except`:

    ```pascal
    Result := TJSONObject.Create;
    try
      // fill it in
    except
      FreeAndNil(Result);
      raise;
    end;
    ```

  - **An item for a list:** add it to its owner first and fill it in afterwards, so it needs no `try` of its own. A constructor filling its fields needs none either: the destructor frees them.
- A routine does one job. Split it when it does several jobs, when you would want a comment naming a section of it, or when nesting goes past about three levels. Around 40 lines, stop and check; past 80, have a reason. Length is only a prompt: a flat `case` with one branch per type, or plain setup, is fine at any length, and splitting it would only scatter what one screen shows. Nested helper routines are a good way to split without adding to a unit's public surface.
- Space controls with `Sloper.UI.Spacing` (`ControlGap`, `SpaceChildren`, `SpaceBetween`, `SpaceButtons`), not with numbers of their own, so the apps keep one spacing (see Spacing in `documents/design/design-app.md`).
- Recursion inside a function needs brackets: in ObjFPC mode a bare `ParseUnary` inside `ParseUnary` means the result variable, so write `ParseUnary()`.
- In a unit that uses `Windows`, even only under `{$IFDEF WINDOWS}`, call `SysUtils.GetEnvironmentVariable`: the `Windows` unit's own `GetEnvironmentVariable` hides it, and only a Windows build fails.
- Don't index an array with a call that can grow it (`Tokens[Add(...)] := ...`): Free Pascal may take the array's address before the call reallocates it. Store the index first.
- Compare floats with a tolerance, and never compare a `double` with an untyped float constant such as `MaxDouble`: on x86_64 Linux the constant is evaluated as 80-bit `Extended` and never equals the `double` (see `documents/known-issues.md`).

## TypeScript

The web version's code in the browser is TypeScript, in the npm project in `web/` (the design app in `web/src`, the spike's page in `web/engine/browser`). Three tools check it, and none of their errors may be left in a commit:

| Tool | Checks | Configuration |
| --- | --- | --- |
| `tsc` (TypeScript 7) | Types, in strict mode with `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` | `tsconfig.json` |
| Oxlint, with `oxlint-tsgolint` | Bugs the compiler lets through: correctness, suspicious and performance rules, and type-aware rules on typescript-go (promises left unawaited or misused, `any` used unchecked, needless assertions, switches that miss a case, truthiness of non-booleans, `==`) | `.oxlintrc.json` |
| Prettier | Layout: 2-space indents, single quotes, trailing commas, lines of at most 120 characters | `.prettierrc.json` |

- **Running them:** `npm run check` in the folder runs all three, `npm run format` lays the files out, and `npm run build` checks before it bundles. `./opensloper-make.sh check` and `./opensloper-make.sh format` run them too when given no files, after the Pascal; they say so and go on without them when npm or the folder's packages are missing. npm comes from the repository's `venv` through `nodeenv` (see `web/engine/README.md`).
- **Oxlint, not ESLint** (chosen 2026-11-18): `typescript-eslint` does not support TypeScript 7 yet, and Oxlint's type-aware rules run on typescript-go, the TypeScript 7 compiler. Oxlint warnings fail too (`denyWarnings`), and a disable comment that no longer disables anything is an error. `unicorn/require-post-message-target-origin` is off: it is for `window.postMessage`, and a worker's `postMessage` takes no target origin.
- **No `any`.** A value from outside, such as `JSON.parse` or a Wasm export, is typed `unknown` and checked before it is used (`src/engine/replies.ts`): an `isRecord` guard, then each field tested for its type.
- **Disable comments say why**, on the line above, and are for what a rule cannot see: a loop that awaits one call at a time on purpose, as a drag does, or the Wasm boundary, where a function's signature cannot be checked at run time (`exported` in `src/engine/worker.ts`). Each covers one rule on one line (`oxlint-disable-next-line rule`).
- **Names** follow TypeScript's usage rather than the Pascal rules: `camelCase` for variables and functions, `PascalCase` for types, `UPPER_CASE` for constants, and descriptive names, no single letters, as in Pascal.
- **Messages between page and worker** are a union with a `kind` field (`src/engine/messages.ts`), so `switch (message.kind)` is checked for every kind.
- **Node scripts** are TypeScript too, run by Node as they are (`bundle.ts`, `tests/design.ts`), and checked like the rest.
- **Tests:** unit tests are `web/tests/*.test.ts`, run by `node --test` (`npm test`); a copy of Pascal logic, such as `view.ts`, is tested with the Pascal tests' cases and numbers. `tests/design.ts` drives the built app in headless Chromium as a user would.
- **Mirror the desktop.** A module is named after the `src/ui` unit it stands for, with the same classes (`PatternCanvas`, `PatternPainter`, `PointTool`); editing logic stays in Pascal behind the editor methods, so the TypeScript only draws and handles input.

## Releases and versioning

The version number is chosen at release time, from what actually changed, not decided in advance.

- **One source.** `APP_VERSION` in `src/core/sloper.core.version.pas`. `--version`, the API's version, the About box, the downloads and the docs site all read it.
- **Between releases** the version is the last release with `+dev` (`0.10.0+dev`), so a development build never claims to be a release. `+` is SemVer build metadata: it sorts after the release it follows, not before as `-dev` would.
- **Changelog.** Add each notable change under `## Unreleased` at the top of `CHANGELOG.md`, under Added, Changed, Fixed or Removed.
- **Choosing the number** follows SemVer.
  - Before 1.0, a breaking change bumps the minor (`0.10.0` → `0.11.0`). Breaking means the pattern or measurement file format, Automation API method or field names, or CLI output that scripts read.
  - Before 1.0, features and fixes bump the patch (`0.10.0` → `0.10.1`).
  - From 1.0: breaking → major, features → minor, fixes → patch.
- **Releasing.**
  1. `./opensloper-make.sh bump minor` (or `patch`, `major`, `X.Y.Z`) sets `APP_VERSION` and renames `Unreleased` to `## 0.11.0 — YYYY-MM-DD`. Commit it.
  2. Merge it into the `release` branch. The release workflow builds the downloads, tags `v0.11.0` and publishes the release with that section as its notes. It refuses a `+dev` version.
  3. `./opensloper-make.sh bump dev` sets `0.11.0+dev` and starts an empty `Unreleased`. Commit it on `development`.
- **The file format version is separate.** `.sloper` and measurement files carry their own `version`, which changes only when the format does, not with each release.
