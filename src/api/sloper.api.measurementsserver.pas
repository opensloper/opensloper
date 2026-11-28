{
  OpenSloper - parametric sewing pattern drafting
  Copyright (C) 2026 The OpenSloper authors

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
}


// The web Measurements page's independent measurement document.
unit Sloper.API.MeasurementsServer;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, fpjson, Sloper.API.Methods, Sloper.Core.Catalogue, Sloper.Core.Units, Sloper.Document.MeasurementDocument;

type
  TMeasurementsApiServer = class
  private
    FDocument: TMeasurementDocument;
    // The measurement catalogue, as the page supplies it; empty until then
    FCatalogue: TCatalogue;
    // The warning for a value outside its catalogue entry's typical range,
    // as the desktop's status bar gives it; '' inside it or with no entry
    function RangeWarning(Index, Size: integer; AUnit: TMeasureUnit): string;
    // A catalogue that cannot be read is refused, and the one loaded stays
    function DoCatalogue(const Text: string): TJSONObject;
    function DoCatalogueList(Params: TJSONObject): TJSONObject;
    function DoCatalogueEntry(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
    function DoAddKnown(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
    // The set's keys, which the body figure draws and picks from
    function SetKeys: TStringArray;
    function DoFigure(Params: TJSONObject): TJSONObject;
    function DoFigureAt(Params: TJSONObject): TJSONObject;
    function DoCheckPattern(Params: TJSONObject): boolean;
    function DoAddMissing(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
    // The set as its file holds it, and as the table shows it in AUnit
    function State(AUnit: TMeasureUnit): TJSONObject;
    // The measurement with the key given, refused when there is none
    function KeyIndex(Params: TJSONObject): integer;
    function DoSet(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
    function DoAdd(AUnit: TMeasureUnit): TJSONObject;
    function DoMove(Params: TJSONObject): boolean;
    // The size given by its index, refused when there is none
    function SizeIndex(Params: TJSONObject; const Name: string): integer;
    procedure DoSizeEdit(const Method: string; Params: TJSONObject);
  public
    constructor Create;
    destructor Destroy; override;
    function CallMethod(const Method: string; Params: TJSONObject): TJSONData;
  end;

const
  MEASUREMENTS_PREFIX = 'measurements_';

function MeasurementsMethods: TApiMethodArray;

implementation

uses
  Math, Sloper.API.Rpc, Sloper.API.Server, Sloper.Core.Geometry, Sloper.Core.JSON,
  Sloper.Core.Measurements, Sloper.Core.Shortcuts, Sloper.Output.BodyFigureSVG;

resourcestring
  rsMeasurementsOpen = 'Opens a measurement set supplied by the browser';
  rsMeasurementsText = 'The contents of the .slm file';
  rsMeasurementsUnit = 'The unit the table shows values in: mm (the default), cm or in';
  rsMeasurementsState = 'Reads the current measurement set';
  rsMeasurementsTables = 'The Measurements app''s keyboard shortcuts';
  rsMeasurementsTablesReturns = '`shortcuts` for the commands, as in the desktop app';
  rsMeasurementsSnapshot = 'The set as text, without counting it as saved';
  rsMeasurementsSnapshotReturns = '`text`, the contents of the .slm file';
  rsMeasurementsSaved = 'Counts the text written to a file as saved. Later edits remain unsaved';
  rsMeasurementsMarkUnsaved = 'Counts recovered work as unsaved, without making an undo step';
  rsMeasurementsSet = 'A cell of the table as typed: a key renames the measurement, a value is a number in ' +
    '`unit`, or blank to clear it in a size table, and a description is kept as typed; one undo step. A refused ' +
    'edit answers `done` false with the `reason`';
  rsMeasurementsSetReturns = '`done`, `reason`, the measurement''s `key` afterwards, `warning` for a value ' +
    'outside its catalogue entry''s typical range (else empty), and the state, as measurements_state';
  rsMeasurementsKey = 'The measurement, by its key';
  rsMeasurementsColumn = 'Which cell: key, value or description';
  rsMeasurementsSize = 'For a value, the size by its index; 0 in a set without sizes';
  rsMeasurementsCellText = 'The cell''s text as typed';
  rsMeasurementsAdd = 'Adds a measurement at the end with a free key and no description, for its key to be typed; ' +
    'one undo step';
  rsMeasurementsAddReturns = 'Its `key`, and the state, as measurements_state';
  rsMeasurementsDelete = 'Deletes a measurement; one undo step. Patterns using it show it as missing';
  rsMeasurementsMove = 'Moves a measurement to another place in the table; one undo step';
  rsMeasurementsIndex = 'Its place afterwards, from 0';
  rsMeasurementsUndo = 'Undoes the last change to the set';
  rsMeasurementsRedo = 'Makes the change undone again';
  rsMeasurementsEditReturns = 'The state, as measurements_state';
  rsMeasurementsSetName = 'Sets the set''s name, as typed; one undo step, none when it is unchanged';
  rsMeasurementsSetNotes = 'Sets the set''s notes, as typed; one undo step, none when they are unchanged';
  rsMeasurementsHeaderText = 'The text as typed';
  rsMeasurementsAddSize = 'Adds a size at the end of the table: a set without sizes becomes a size table, its ' +
    'values the new size''s; one undo step';
  rsMeasurementsSizeName = 'The size''s name, such as 12 or M';
  rsMeasurementsRenameSize = 'Renames a size; one undo step';
  rsMeasurementsDeleteSize = 'Deletes a size and its values; one undo step. The last size cannot be deleted';
  rsMeasurementsMoveSize = 'Moves a size to another column; one undo step';
  rsMeasurementsSizeIndex = 'The size, by its index from 0';
  rsMeasurementsSizePlace = 'Its index afterwards, from 0';
  rsMeasurementsCatalogue = 'Loads the measurement catalogue, which the page supplies as text; the table works ' +
    'without it. One that cannot be read is refused, and the one loaded stays';
  rsMeasurementsCatalogueText = 'The contents of measurement-catalogue.json';
  rsMeasurementsCatalogueReturns = '`count`, the number of measurements it describes';
  rsMeasurementsCatalogueList = 'The catalogue''s measurements that the set does not have yet, as the desktop''s ' +
    'Add From the Catalogue lists them';
  rsMeasurementsGroup = 'Only this group: heights, circumferences, widths, arm, leg, crotch, head, hand or foot; ' +
    'empty for all';
  rsMeasurementsSearch = 'Only those whose key, name or description has this text';
  rsMeasurementsCatalogueListReturns = '`entries`, each with `key` and `name`';
  rsMeasurementsCatalogueEntry = 'A catalogue entry, for the panel under the list';
  rsMeasurementsCatalogueKey = 'The entry, by its key';
  rsMeasurementsCatalogueEntryReturns = '`found`, and when found `key`, `name`, `description`, `howTo`, and ' +
    '`rangeMin` and `rangeMax`, its typical range as text in the unit';
  rsMeasurementsAddKnown = 'Adds a catalogue measurement at the end, with its key and description; one undo step. ' +
    'A key the set has is refused';
  rsMeasurementsAddKnownReturns = 'Its `key`, and the state, as measurements_state';
  rsMeasurementsFigure = 'The body figure as SVG, as the desktop draws it: the front, back and side outlines, ' +
    'the set''s measurements on them, and one highlighted';
  rsMeasurementsFigureWidth = 'Its width in pixels';
  rsMeasurementsFigureHeight = 'Its height in pixels';
  rsMeasurementsHighlight = 'The measurement to highlight, by its key; it need not be in the set';
  rsMeasurementsFigureReturns = '`svg`, the figure''s SVG text';
  rsMeasurementsFigureAt = 'The set''s measurement drawn under a point of the body figure, as a click picks it';
  rsMeasurementsFigureX = 'The point, in pixels from the figure''s left';
  rsMeasurementsFigureY = 'The point, in pixels from the figure''s top';
  rsMeasurementsFigureAtReturns = '`key`, empty when no measurement is drawn there';
  rsMeasurementsCheckPattern = 'Checks the set against a pattern from now on, which the page supplies as text: ' +
    'the state''s `missing` lists what it uses that the set cannot give it. A file that is not a pattern is ' +
    'refused, and the pattern before stays';
  rsMeasurementsPatternName = 'The pattern file''s name, as the page shows it';
  rsMeasurementsPatternText = 'The contents of the .sloper file';
  rsMeasurementsStopCheck = 'Stops checking against a pattern';
  rsMeasurementsAddMissing = 'Adds a measurement the pattern needs at the end, with the catalogue''s description ' +
    'when it has one; one undo step. A key the set has is refused';
  rsMeasurementsMissingKey = 'The measurement, by its key';
  rsMeasurementsPatternFailed = 'Could not read %s: %s';
  rsMeasurementsNoEntry = 'The catalogue has no measurement %s';
  rsMeasurementsOutsideRange = '@%s is outside the usual %s to %s %s; it is kept, in case that is right';
  rsMeasurementsNoKey = 'There is no measurement @%s';
  rsMeasurementsNothingToUndo = 'There is nothing to undo';
  rsMeasurementsNothingToRedo = 'There is nothing to redo';
  rsMeasurementsStateReturns = 'The current `set`, as in a .slm file, and the table as the page shows it: `unit`, ' +
    '`sizes` (none for a set without sizes) and `rows`, each with `key`, `values` (one for each size, or the one ' +
    'value, as text in the unit, empty where there is none), `outside` (for each value, true when it is outside ' +
    'its catalogue entry''s typical range) and `description`; `modified`, `canUndo`, `canRedo` ' +
    'and `undo`, the name of the step Undo would take; `pattern`, the name of the pattern checked against, or ' +
    'empty, and `missing`, what it uses that the set cannot give it, each with `key` and `sizes` (the sizes with ' +
    'no value; none when the set lacks the key)';

function MeasurementsMethods: TApiMethodArray;
begin
  Result := nil;
  AddApiMethod(Result, 'measurements_open', rsMeasurementsOpen, rsMeasurementsStateReturns);
  AddApiParam(Result, 'text', apText, True, rsMeasurementsText);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_state', rsMeasurementsState, rsMeasurementsStateReturns, True);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_tables', rsMeasurementsTables, rsMeasurementsTablesReturns, True);
  AddApiMethod(Result, 'measurements_text', rsMeasurementsSnapshot, rsMeasurementsSnapshotReturns, True);
  AddApiMethod(Result, 'measurements_saved', rsMeasurementsSaved, rsMeasurementsStateReturns);
  AddApiParam(Result, 'text', apText, True, rsMeasurementsText);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_mark_unsaved', rsMeasurementsMarkUnsaved, rsMeasurementsStateReturns);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_set', rsMeasurementsSet, rsMeasurementsSetReturns);
  AddApiParam(Result, 'key', apText, True, rsMeasurementsKey);
  AddApiParam(Result, 'column', apChoice, True, rsMeasurementsColumn, 'key, value, description');
  AddApiParam(Result, 'size', apNumber, False, rsMeasurementsSize);
  AddApiParam(Result, 'text', apText, True, rsMeasurementsCellText);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_add', rsMeasurementsAdd, rsMeasurementsAddReturns);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_delete', rsMeasurementsDelete, rsMeasurementsEditReturns);
  AddApiParam(Result, 'key', apText, True, rsMeasurementsKey);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_move', rsMeasurementsMove, rsMeasurementsEditReturns);
  AddApiParam(Result, 'key', apText, True, rsMeasurementsKey);
  AddApiParam(Result, 'index', apNumber, True, rsMeasurementsIndex);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_set_name', rsMeasurementsSetName, rsMeasurementsEditReturns);
  AddApiParam(Result, 'text', apText, True, rsMeasurementsHeaderText);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_set_notes', rsMeasurementsSetNotes, rsMeasurementsEditReturns);
  AddApiParam(Result, 'text', apText, True, rsMeasurementsHeaderText);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_add_size', rsMeasurementsAddSize, rsMeasurementsEditReturns);
  AddApiParam(Result, 'name', apText, True, rsMeasurementsSizeName);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_rename_size', rsMeasurementsRenameSize, rsMeasurementsEditReturns);
  AddApiParam(Result, 'size', apNumber, True, rsMeasurementsSizeIndex);
  AddApiParam(Result, 'name', apText, True, rsMeasurementsSizeName);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_delete_size', rsMeasurementsDeleteSize, rsMeasurementsEditReturns);
  AddApiParam(Result, 'size', apNumber, True, rsMeasurementsSizeIndex);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_move_size', rsMeasurementsMoveSize, rsMeasurementsEditReturns);
  AddApiParam(Result, 'size', apNumber, True, rsMeasurementsSizeIndex);
  AddApiParam(Result, 'index', apNumber, True, rsMeasurementsSizePlace);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_catalogue', rsMeasurementsCatalogue, rsMeasurementsCatalogueReturns);
  AddApiParam(Result, 'text', apText, True, rsMeasurementsCatalogueText);
  AddApiMethod(Result, 'measurements_catalogue_list', rsMeasurementsCatalogueList, rsMeasurementsCatalogueListReturns,
    True);
  AddApiParam(Result, 'group', apText, False, rsMeasurementsGroup);
  AddApiParam(Result, 'search', apText, False, rsMeasurementsSearch);
  AddApiMethod(Result, 'measurements_catalogue_entry', rsMeasurementsCatalogueEntry,
    rsMeasurementsCatalogueEntryReturns, True);
  AddApiParam(Result, 'key', apText, True, rsMeasurementsCatalogueKey);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_add_known', rsMeasurementsAddKnown, rsMeasurementsAddKnownReturns);
  AddApiParam(Result, 'key', apText, True, rsMeasurementsCatalogueKey);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_figure', rsMeasurementsFigure, rsMeasurementsFigureReturns, True);
  AddApiParam(Result, 'width', apNumber, True, rsMeasurementsFigureWidth);
  AddApiParam(Result, 'height', apNumber, True, rsMeasurementsFigureHeight);
  AddApiParam(Result, 'highlight', apText, False, rsMeasurementsHighlight);
  AddApiMethod(Result, 'measurements_figure_at', rsMeasurementsFigureAt, rsMeasurementsFigureAtReturns, True);
  AddApiParam(Result, 'width', apNumber, True, rsMeasurementsFigureWidth);
  AddApiParam(Result, 'height', apNumber, True, rsMeasurementsFigureHeight);
  AddApiParam(Result, 'x', apNumber, True, rsMeasurementsFigureX);
  AddApiParam(Result, 'y', apNumber, True, rsMeasurementsFigureY);
  AddApiMethod(Result, 'measurements_check_pattern', rsMeasurementsCheckPattern, rsMeasurementsEditReturns);
  AddApiParam(Result, 'name', apText, True, rsMeasurementsPatternName);
  AddApiParam(Result, 'text', apText, True, rsMeasurementsPatternText);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_stop_check', rsMeasurementsStopCheck, rsMeasurementsEditReturns);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_add_missing', rsMeasurementsAddMissing, rsMeasurementsAddKnownReturns);
  AddApiParam(Result, 'key', apText, True, rsMeasurementsMissingKey);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_undo', rsMeasurementsUndo, rsMeasurementsEditReturns);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
  AddApiMethod(Result, 'measurements_redo', rsMeasurementsRedo, rsMeasurementsEditReturns);
  AddApiParam(Result, 'unit', apChoice, False, rsMeasurementsUnit, string.Join(', ', MEASURE_UNIT_NAMES));
end;

// The unit asked for, else mm, as the desktop's Show in box starts
function TableUnit(Params: TJSONObject): TMeasureUnit;
begin
  Result := muMillimetre;
  if Assigned(Params) and Assigned(Params.Find('unit')) then
    Result := TMeasureUnit(ChoiceParam(Params, 'unit', MEASURE_UNIT_NAMES));
end;

constructor TMeasurementsApiServer.Create;
begin
  inherited Create;
  FDocument := TMeasurementDocument.Create;
  FCatalogue := TCatalogue.Create;
end;

destructor TMeasurementsApiServer.Destroy;
begin
  FreeAndNil(FCatalogue);
  FreeAndNil(FDocument);
  inherited Destroy;
end;

// A row's values as the desktop's grid shows them: one a size, or the one
// value of a set without sizes, in AUnit
function TMeasurementsApiServer.State(AUnit: TMeasureUnit): TJSONObject;
var
  Snapshot, Answer, Row: TJSONObject;
  Sizes, Rows, Values, Outside, Missing, MissingSizes: TJSONArray;
  Item: TMissingMeasurement;
  Entry: TCatalogueEntry;
  Table: TMeasurementSet;
  Index, Size: integer;
  Reason: string;
begin
  if not ParseJSONObject(FDocument.SnapshotText, Snapshot, Reason) then
    raise EApiError.Create(RPC_INTERNAL_ERROR, Reason);
  Answer := TJSONObject.Create(['set', Snapshot, 'unit', MEASURE_UNIT_NAMES[AUnit]]);
  try
    Table := FDocument.Measurements;
    Sizes := TJSONArray.Create;
    Answer.Add('sizes', Sizes);
    for Size := 0 to Table.SizeCount - 1 do
      Sizes.Add(Table.Sizes[Size]);
    Rows := TJSONArray.Create;
    Answer.Add('rows', Rows);
    for Index := 0 to Table.Count - 1 do
    begin
      Values := TJSONArray.Create;
      Outside := TJSONArray.Create;
      Entry := FCatalogue.Find(Table[Index].Key);
      for Size := 0 to Max(Table.SizeCount, 1) - 1 do
        if Table[Index].HasValueFor(Size) then
        begin
          Values.Add(FormatMeasure(Table[Index].ValueFor(Size), AUnit));
          Outside.Add(Assigned(Entry) and not Entry.InRange(Table[Index].ValueFor(Size)));
        end
        else
        begin
          Values.Add('');
          Outside.Add(False);
        end;
      Row := TJSONObject.Create(['key', Table[Index].Key, 'values', Values, 'outside', Outside, 'description',
        Table[Index].Description]);
      Rows.Add(Row);
    end;
    Answer.Add('modified', FDocument.Modified);
    Answer.Add('canUndo', FDocument.CanUndo);
    Answer.Add('canRedo', FDocument.CanRedo);
    Answer.Add('undo', FDocument.UndoDescription);
    Answer.Add('pattern', FDocument.PatternFile);
    Missing := TJSONArray.Create;
    Answer.Add('missing', Missing);
    for Item in FDocument.Missing do
    begin
      MissingSizes := TJSONArray.Create;
      for Size := 0 to High(Item.Sizes) do
        MissingSizes.Add(Item.Sizes[Size]);
      Missing.Add(TJSONObject.Create(['key', Item.Key, 'sizes', MissingSizes]));
    end;
    Result := Answer;
  except
    FreeAndNil(Answer);
    raise;
  end;
end;

function TMeasurementsApiServer.KeyIndex(Params: TJSONObject): integer;
var
  Key: string;
begin
  Key := RequireString(Params, 'key');
  Result := FDocument.Measurements.IndexOf(Key);
  if Result < 0 then
    raise EApiError.Create(RPC_REFUSED, Format(rsMeasurementsNoKey, [Key]));
end;

// As the desktop window commits a cell: a key trimmed, a value through
// SetValueText in the unit the table shows, a description as typed
function TMeasurementsApiServer.DoSet(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
var
  Index, Size: integer;
  Text, Reason: string;
  Done: boolean;
  SizeNumber: double;
begin
  Index := KeyIndex(Params);
  Text := RequireString(Params, 'text');
  Reason := '';
  case ChoiceParam(Params, 'column', ['key', 'value', 'description']) of
    0: Done := FDocument.RenameKey(Index, Trim(Text), Reason);
    1:
    begin
      SizeNumber := 0;
      OptionalNumber(Params, 'size', SizeNumber);
      Size := Round(SizeNumber);
      if (Size < 0) or (Size >= Max(FDocument.Measurements.SizeCount, 1)) then
        raise EApiError.Create(RPC_INVALID_PARAMS, Format(rsApiMissingParam, ['size']));
      Done := FDocument.SetValueText(Index, Size, Text, AUnit, Reason);
    end;
    else
    begin
      FDocument.SetDescription(Index, Text);
      Done := True;
    end;
  end;
  Result := State(AUnit);
  Result.Add('done', Done);
  Result.Add('reason', Reason);
  Result.Add('key', FDocument.Measurements[Index].Key);
  if Done and (ChoiceParam(Params, 'column', ['key', 'value', 'description']) = 1) then
    Result.Add('warning', RangeWarning(Index, Size, AUnit))
  else
    Result.Add('warning', '');
end;

function TMeasurementsApiServer.DoAdd(AUnit: TMeasureUnit): TJSONObject;
var
  Key: string;
begin
  Key := FDocument.AddMeasurement.Key;
  Result := State(AUnit);
  Result.Add('key', Key);
end;

// False when the place is outside the table
function TMeasurementsApiServer.DoMove(Params: TJSONObject): boolean;
var
  Index: integer;
  Place: double;
begin
  Index := KeyIndex(Params);
  Place := -1;
  OptionalNumber(Params, 'index', Place);
  Result := (Round(Place) >= 0) and (Round(Place) < FDocument.Measurements.Count);
  if Result and (Round(Place) <> Index) then
    FDocument.MoveMeasurement(Index, Round(Place));
end;

function TMeasurementsApiServer.RangeWarning(Index, Size: integer; AUnit: TMeasureUnit): string;
var
  Entry: TCatalogueEntry;
  Measurement: TMeasurement;
begin
  Result := '';
  Measurement := FDocument.Measurements[Index];
  Entry := FCatalogue.Find(Measurement.Key);
  if Assigned(Entry) and Measurement.HasValueFor(Size) and not Entry.InRange(Measurement.ValueFor(Size)) then
    Result := Format(rsMeasurementsOutsideRange, [Entry.Key, FormatMeasure(Entry.RangeMin, AUnit),
      FormatMeasure(Entry.RangeMax, AUnit), MEASURE_UNIT_NAMES[AUnit]]);
end;

function TMeasurementsApiServer.DoCatalogue(const Text: string): TJSONObject;
var
  Loaded: TCatalogue;
  Reason: string;
begin
  Loaded := TCatalogue.Create;
  if not Loaded.LoadFromText(Text, Reason) then
  begin
    FreeAndNil(Loaded);
    raise EApiError.Create(RPC_REFUSED, Reason);
  end;
  FreeAndNil(FCatalogue);
  FCatalogue := Loaded;
  Result := TJSONObject.Create(['count', FCatalogue.Count]);
end;

// Only what the set does not have yet, since a set keeps what a person needs
function TMeasurementsApiServer.DoCatalogueList(Params: TJSONObject): TJSONObject;
var
  Group, Search: string;
  Entries: TJSONArray;
  Entry: TCatalogueEntry;
begin
  Group := OptionalString(Params, 'group');
  Search := OptionalString(Params, 'search');
  Entries := TJSONArray.Create;
  Result := TJSONObject.Create(['entries', Entries]);
  for Entry in FCatalogue.Search(Group, Search) do
    if not Assigned(FDocument.Measurements.Find(Entry.Key)) then
      Entries.Add(TJSONObject.Create(['key', Entry.Key, 'name', Entry.Name]));
end;

function TMeasurementsApiServer.DoCatalogueEntry(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
var
  Entry: TCatalogueEntry;
begin
  Entry := FCatalogue.Find(RequireString(Params, 'key'));
  if not Assigned(Entry) then
    Exit(TJSONObject.Create(['found', False]));
  Result := TJSONObject.Create(['found', True, 'key', Entry.Key, 'name', Entry.Name, 'description',
    Entry.Description, 'howTo', Entry.HowTo, 'rangeMin', FormatMeasure(Entry.RangeMin, AUnit), 'rangeMax',
    FormatMeasure(Entry.RangeMax, AUnit), 'unit', MEASURE_UNIT_NAMES[AUnit]]);
end;

// As the desktop's Add to the file: the entry's key and description
function TMeasurementsApiServer.DoAddKnown(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
var
  Key, Reason: string;
  Entry: TCatalogueEntry;
begin
  Key := RequireString(Params, 'key');
  Entry := FCatalogue.Find(Key);
  if not Assigned(Entry) then
    raise EApiError.Create(RPC_REFUSED, Format(rsMeasurementsNoEntry, [Key]));
  if not FDocument.AddKnown(Entry.Key, Entry.Description, Reason) then
    raise EApiError.Create(RPC_REFUSED, Reason);
  Result := State(AUnit);
  Result.Add('key', Entry.Key);
end;

// A number the method needs, refused when it is missing
function NumberParam(Params: TJSONObject; const Name: string): double;
begin
  Result := 0;
  if not OptionalNumber(Params, Name, Result) then
    raise EApiError.Create(RPC_INVALID_PARAMS, Format(rsApiMissingParam, [Name]));
end;

function TMeasurementsApiServer.SetKeys: TStringArray;
var
  Index: integer;
begin
  Result := nil;
  SetLength(Result, FDocument.Measurements.Count);
  for Index := 0 to High(Result) do
    Result[Index] := FDocument.Measurements[Index].Key;
end;

function TMeasurementsApiServer.DoFigure(Params: TJSONObject): TJSONObject;
begin
  Result := TJSONObject.Create(['svg', BodyFigureToSVG(FCatalogue, NumberParam(Params, 'width'),
    NumberParam(Params, 'height'), SetKeys, OptionalString(Params, 'highlight'))]);
end;

function TMeasurementsApiServer.DoFigureAt(Params: TJSONObject): TJSONObject;
begin
  Result := TJSONObject.Create(['key', BodyFigureKeyAt(FCatalogue, NumberParam(Params, 'width'),
    NumberParam(Params, 'height'), Vec2(NumberParam(Params, 'x'), NumberParam(Params, 'y')), SetKeys)]);
end;

// A file that does not read as a pattern says why, and the check before stays
function TMeasurementsApiServer.DoCheckPattern(Params: TJSONObject): boolean;
var
  Name, Reason: string;
begin
  Name := RequireString(Params, 'name');
  Result := FDocument.UsePatternText(Name, RequireString(Params, 'text'), Reason);
  if not Result then
    raise EApiError.Create(RPC_REFUSED, Format(rsMeasurementsPatternFailed, [Name, Reason]));
end;

// As the desktop's Add or go to it for a key the set lacks
function TMeasurementsApiServer.DoAddMissing(Params: TJSONObject; AUnit: TMeasureUnit): TJSONObject;
var
  Key, Description, Reason: string;
  Entry: TCatalogueEntry;
begin
  Key := RequireString(Params, 'key');
  Description := '';
  Entry := FCatalogue.Find(Key);
  if Assigned(Entry) then
    Description := Entry.Description;
  if not FDocument.AddKnown(Key, Description, Reason) then
    raise EApiError.Create(RPC_REFUSED, Reason);
  Result := State(AUnit);
  Result.Add('key', Key);
end;

function TMeasurementsApiServer.SizeIndex(Params: TJSONObject; const Name: string): integer;
var
  Number: double;
begin
  Number := -1;
  OptionalNumber(Params, Name, Number);
  Result := Round(Number);
  if (Result < 0) or (Result >= FDocument.Measurements.SizeCount) then
    raise EApiError.Create(RPC_INVALID_PARAMS, Format(rsApiMissingParam, [Name]));
end;

// As the desktop's size buttons: a name refused, or the last size, says why
procedure TMeasurementsApiServer.DoSizeEdit(const Method: string; Params: TJSONObject);
var
  Index: integer;
  Done: boolean;
  Reason: string;
begin
  Reason := '';
  Done := True;
  case Method of
    'measurements_add_size': Done := FDocument.AddSize(RequireString(Params, 'name'), Reason);
    'measurements_rename_size':
    begin
      Index := SizeIndex(Params, 'size');
      Done := FDocument.RenameSize(Index, RequireString(Params, 'name'), Reason);
    end;
    'measurements_delete_size': Done := FDocument.DeleteSize(SizeIndex(Params, 'size'), Reason);
    else
    begin
      Index := SizeIndex(Params, 'size');
      if SizeIndex(Params, 'index') <> Index then
        FDocument.MoveSize(Index, SizeIndex(Params, 'index'));
    end;
  end;
  if not Done then
    raise EApiError.Create(RPC_REFUSED, Reason);
end;

function TMeasurementsApiServer.CallMethod(const Method: string; Params: TJSONObject): TJSONData;
var
  Reason: string;
  AUnit: TMeasureUnit;
begin
  // A bad unit is refused before the set changes
  AUnit := TableUnit(Params);
  case Method of
    'measurements_open':
      if not FDocument.OpenText(RequireString(Params, 'text'), Reason) then
        raise EApiError.Create(RPC_REFUSED, Reason);
    'measurements_state': ;
    'measurements_tables': Exit(TJSONObject.Create(['shortcuts', ShortcutsToJSON(saMeasurements)]));
    'measurements_text': Exit(TJSONObject.Create(['text', FDocument.SnapshotText]));
    'measurements_saved': FDocument.MarkTextSaved(RequireString(Params, 'text'));
    'measurements_mark_unsaved': FDocument.MarkUnsaved;
    'measurements_catalogue': Exit(DoCatalogue(RequireString(Params, 'text')));
    'measurements_catalogue_list': Exit(DoCatalogueList(Params));
    'measurements_catalogue_entry': Exit(DoCatalogueEntry(Params, AUnit));
    'measurements_add_known': Exit(DoAddKnown(Params, AUnit));
    'measurements_figure': Exit(DoFigure(Params));
    'measurements_check_pattern': DoCheckPattern(Params);
    'measurements_stop_check': FDocument.UsePattern('', Reason);
    'measurements_add_missing': Exit(DoAddMissing(Params, AUnit));
    'measurements_figure_at': Exit(DoFigureAt(Params));
    'measurements_set': Exit(DoSet(Params, AUnit));
    'measurements_add': Exit(DoAdd(AUnit));
    'measurements_delete': FDocument.DeleteMeasurement(KeyIndex(Params));
    'measurements_move':
      if not DoMove(Params) then
        raise EApiError.Create(RPC_INVALID_PARAMS, Format(rsApiMissingParam, ['index']));
    // As the desktop's fields: unchanged text makes no undo step
    'measurements_set_name':
      if RequireString(Params, 'text') <> FDocument.Measurements.Name then
        FDocument.SetName(RequireString(Params, 'text'));
    'measurements_set_notes':
      if RequireString(Params, 'text') <> FDocument.Measurements.Notes then
        FDocument.SetNotes(RequireString(Params, 'text'));
    'measurements_add_size', 'measurements_rename_size', 'measurements_delete_size', 'measurements_move_size':
      DoSizeEdit(Method, Params);
    'measurements_undo':
    begin
      if not FDocument.CanUndo then
        raise EApiError.Create(RPC_REFUSED, rsMeasurementsNothingToUndo);
      FDocument.Undo;
    end;
    'measurements_redo':
    begin
      if not FDocument.CanRedo then
        raise EApiError.Create(RPC_REFUSED, rsMeasurementsNothingToRedo);
      FDocument.Redo;
    end;
    else
      raise EApiError.Create(RPC_METHOD_NOT_FOUND, Format(rsApiNoMethod, [Method]));
  end;
  Result := State(AUnit);
end;

end.
