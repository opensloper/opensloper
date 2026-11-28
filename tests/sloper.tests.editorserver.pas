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

// Tests of the editor_ methods the web editor calls: the scene, snapping,
// picking and adding a point from a click.
unit Sloper.Tests.EditorServer;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, fpcunit, testregistry, fpjson, Sloper.Tests.TestCase, Sloper.API.EditorServer, Sloper.API.Rpc,
  Sloper.Core.Draft, Sloper.Editor.ToolEdits;

type
  TTestEditorServer = class(TOSTestCase)
  private
    FServer: TEditorApiServer;
    FReply: TJSONObject;
    procedure Call(const Method: string; const Params: string = '{}');
    function Answer: TJSONObject;
    function ErrorCode: integer;
    // The ID of the object with this name; leaves Answer as it was
    function IdOf(const AName: string): integer;
    // A square of four points, A to D, 100 mm a side, with outline edges, made a piece
    procedure AddSquare;
    function Selected: integer;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestScene;
    procedure TestSceneOfEmptyPattern;
    procedure TestSnapToPoint;
    procedure TestSnapToEdge;
    procedure TestSnapFree;
    procedure TestObjectsAt;
    // An undo can take away what the canvas still has selected, for a
    // moment: what only shows things leaves it out rather than refusing (#133)
    procedure TestSelectionGoneByUndo;
    procedure TestObjectsInBox;
    procedure TestAddPointOnEdge;
    // A click on a point picks it and changes nothing
    procedure TestAddPointOnExistingPoint;
    procedure TestLineTool;
    procedure TestLineTooShortIgnored;
    // Lines drawn in open space hang together: each end is offset from the line's start
    procedure TestLineToolChainsOffsets;
    procedure TestCurveToolCarriesOn;
    // The Point tool's drag from a point: onto another point it is offset
    // from that one, in open space it is free, where it is, as one step
    procedure TestRebasePoint;
    // Drags it refuses, saying why, or ignores
    procedure TestRebaseRefused;
    procedure TestShapeTools;
    // A region with a piece already selects it
    procedure TestPieceTool;
    // A click on a notch removes it; on a seam line adds one
    procedure TestNotchTool;
    // Pieces' grainlines and notches, and markers, are in the scene
    procedure TestSceneMarks;
    // Contextual labels: the selection with what it reads and what reads it
    procedure TestLabelKeys;
    procedure TestDependencyArrows;
    // Picking a seam's sides edge by edge, then making it as one step
    procedure TestSeamTool;
    procedure TestImportStamp;
    // The Delete key: refused with the reason while something uses an object
    procedure TestDeleteSelection;
    procedure TestConvertPoint;
    procedure TestGarment;
    procedure TestProblems;
    // Copy gives the fragment's text, paste makes copies of it; cut is copy and delete
    procedure TestCopyAndPaste;
    // The Variables tab's Import…, from the other file's text
    procedure TestImportVariables;
    procedure TestSeamInScene;
    // Notes as the canvas draws them, fields filled in
    procedure TestNotesInScene;
    // A note lies over whatever is under it
    procedure TestNoteHitFirst;
    procedure TestTextTool;
    // A callout's tip must be on something; its text goes where the second click is
    procedure TestCalloutTool;
    procedure TestMissingParamRefused;
    // Claude is not offered the editor's methods as tools
    procedure TestNotOfferedAsTools;
    // The Automation API's methods still answer
    procedure TestApiMethodsStillServed;
    procedure TestComplete;
    // The caret and the word's place count characters, not UTF-8 bytes
    procedure TestCompleteCountsCharacters;
    procedure TestCompleteForObject;
    procedure TestListObjects;
    procedure TestListVariables;
    procedure TestListMeasurements;
    procedure TestSuggest;
    procedure TestSuggestRefused;
    procedure TestTables;
    // What changed since last asked, as the desktop document tells its panels
    procedure TestChanges;
    procedure TestChangesAfterUndo;
    procedure TestChangesOnOpen;
    // A drag is one undo step, with the pattern worked out on every move
    procedure TestDragPoint;
    procedure TestDragCancel;
    procedure TestDragOneField;
    procedure TestDragPartlyFormula;
    procedure TestDragNote;
    // While a drag is open, other changes wait
    procedure TestDragBlocksChanges;
    procedure TestDragRefusals;
    // The selected curves' handles, and the one under a place
    procedure TestHandles;
    procedure TestDragHandle;
    // A handle set by a formula is drawn but not dragged
    procedure TestHandleFormulaRefused;
    // A callout's tip snaps as it moves, changing nothing until it is dropped
    procedure TestDragCalloutTip;
    procedure TestCalloutTipRefusals;
    procedure TestBounds;
    // A list's click, Ctrl+click and Shift+click
    procedure TestListClick;
    // The Variables tab's Add, cells and Delete, each one undo step
    procedure TestVariableEdits;
    // The Measurements tab's unsaved edits, saved to a set given as text
    procedure TestMeasurementEdits;
    procedure TestMeasurementsNewSet;
    procedure TestMeasurementSizeAndScale;
    // With a size table, each suggestion's values at the first and last
    // sizes, and the preview of where it puts the point at them
    procedure TestSuggestGraded;
    // Formula rows say when the suggestions button shows
    procedure TestSuggestRows;
    // A note drawn with its text as typed, draft values worked out, changing nothing
    procedure TestNotePreview;
    // Work in progress: the pattern and its set as text, still counted unsaved
    procedure TestSnapshot;
    procedure TestSaveComplete;
    // A pattern opened again from work in progress counts as not saved
    procedure TestMarkUnsaved;
    // The Features tab's forms: starting values, the selection, and values that follow a change
    procedure TestFeatureForms;
    // Apply adds a feature as one undo step, or says why it cannot
    procedure TestFeatureApply;
    // The Materials tab's list and the dialog's edits, each one undo step
    procedure TestMaterials;
    // Export Draft SVG labels what the canvas labels
    procedure TestExportDraft;
    // Print makes the publish app's tiled PDF of every piece, or says why it cannot
    procedure TestPrint;
    // The Properties tab's rows for a point, an edge, several objects and none
    procedure TestProperties;
    // What a point is placed from, read only, after its name
    procedure TestPointInputRows;
    // Its edits, each one undo step, refused with the reason
    procedure TestPropertyEdits;
    procedure TestOffsetModeEdit;
    procedure TestPointMeasurementEdits;
    // A piece's rows: cut, fold, own allowance, grainline, material and fill
    procedure TestPiecePropertyEdits;
    // A note's rows: text, size, printing, look, font and making it free
    procedure TestNotePropertyEdits;
    // measurements_open and measurements_state on a set of their own: a
    // refused open keeps the set, and the pattern stays open
    procedure TestStandaloneMeasurements;
    procedure TestMeasurementsSaveCompletion;
    // The measurements_ methods are in their own table, not MCP tools
    procedure TestMeasurementsMethodsTable;
    // The table as the page shows it: a column a size, values in the unit asked for
    procedure TestMeasurementsTable;
    // Cells set, rows added, moved and deleted, each one undo step
    procedure TestMeasurementsEdits;
    // Sizes added, renamed, moved and deleted, as the desktop's size buttons
    procedure TestMeasurementsSizes;
    // Name and Notes, each change one undo step
    procedure TestMeasurementsNameAndNotes;
    // The catalogue: listed without what the set has, an entry's details,
    // Add to the file, and values outside the typical range
    procedure TestMeasurementsCatalogue;
    // The body figure as SVG, and the measurement a point on it picks
    procedure TestMeasurementsFigure;
    // Checked against a pattern given as text: what it needs that the set lacks
    procedure TestMeasurementsCheckPattern;
    procedure TestMeasurementsImportExport;
  private
    // The row with this id in the last editor_properties answer
    function PropertyRow(const RowId: string): TJSONObject;
    function HasPropertyRow(const RowId: string): boolean;
    // A callout from B, its text at (150, -40); its ID
    function AddCallout: integer;
    // The field with this id in the last editor_features answer
    function FeatureField(const Id: string): TJSONObject;
    function FeatureValueOf(const Id: string): string;
  end;

implementation

uses
  Sloper.Core.JSON, Sloper.Core.Piece, Sloper.API.Mcp, Sloper.API.Methods, Sloper.API.MeasurementsServer, Sloper.Editor.PanelEdits,
  Sloper.Editor.PropertyRows, Sloper.Editor.FeatureForms, base64,
  Sloper.Core.Pattern, Sloper.Core.PatternFile, Sloper.Core.AppPaths, Sloper.Core.Catalogue, Sloper.Core.Geometry,
  Sloper.Core.Measurements;

const
  TOLERANCE = 1e-6;

procedure TTestEditorServer.SetUp;
begin
  FServer := TEditorApiServer.Create;
  FReply := nil;
end;

procedure TTestEditorServer.TearDown;
begin
  FreeAndNil(FReply);
  FreeAndNil(FServer);
end;

procedure TTestEditorServer.Call(const Method, Params: string);
var
  Err: string;
begin
  FreeAndNil(FReply);
  if not ParseJSONObject(FServer.HandleLine('{"jsonrpc": "2.0", "id": 1, "method": "' + Method + '", "params": ' +
    Params + '}'), FReply, Err) then
    Fail(Err);
end;

function TTestEditorServer.Answer: TJSONObject;
begin
  if not Assigned(FReply.Find('result')) then
    Fail('Expected a result: ' + FReply.AsJSON);
  Result := TJSONObject(FReply.Find('result'));
end;

function TTestEditorServer.ErrorCode: integer;
begin
  if not Assigned(FReply.Find('error')) then
    Fail('Expected an error: ' + FReply.AsJSON);
  Result := TJSONObject(FReply.Find('error')).Get('code', 0);
end;

// Asks with a reply of its own, so the answer being read stays as it was:
// IdOf can sit in an assertion beside Answer
function TTestEditorServer.IdOf(const AName: string): integer;
var
  Reply: TJSONObject;
  Err: string;
begin
  Reply := nil;
  try
    if not ParseJSONObject(FServer.HandleLine('{"jsonrpc": "2.0", "id": 1, "method": "get_object", "params": {"name": "' +
      AName + '"}}'), Reply, Err) then
      Fail(Err);
    if not (Reply.Find('result') is TJSONObject) then
      Fail('No object named ' + AName + ': ' + Reply.AsJSON);
    Result := TJSONObject(Reply.Find('result')).Get('id', 0);
  finally
    FreeAndNil(Reply);
  end;
end;

procedure TTestEditorServer.AddSquare;
begin
  Call('add_point', '{"type": "freePoint", "name": "A", "x": 0, "y": 0}');
  Call('add_point', '{"type": "freePoint", "name": "B", "x": 100, "y": 0}');
  Call('add_point', '{"type": "freePoint", "name": "C", "x": 100, "y": 100}');
  Call('add_point', '{"type": "freePoint", "name": "D", "x": 0, "y": 100}');
  Call('add_edge', '{"type": "line", "start": "A", "end": "B", "role": "outline"}');
  Call('add_edge', '{"type": "line", "start": "B", "end": "C", "role": "outline"}');
  Call('add_edge', '{"type": "line", "start": "C", "end": "D", "role": "outline"}');
  Call('add_edge', '{"type": "line", "start": "D", "end": "A", "role": "outline"}');
  Call('create_piece', '{"x": 50, "y": 50, "name": "Flap"}');
  Answer;
end;

procedure TTestEditorServer.TestScene;
var
  Points, Edges, Pieces, Line: TJSONArray;
  Point, Edge: TJSONObject;
  IdC: integer;
begin
  AddSquare;
  IdC := IdOf('C');
  Call('editor_scene');
  Points := Answer.Arrays['points'];
  Edges := Answer.Arrays['edges'];
  Pieces := Answer.Arrays['pieces'];
  AssertEquals('points', 4, Points.Count);
  AssertEquals('edges', 4, Edges.Count);
  AssertEquals('pieces', 1, Pieces.Count);
  AssertTrue('nothing isolated', Answer.Nulls['isolated']);
  // The rulers and grid count in it
  AssertEquals('the pattern''s unit', 'mm', Answer.Strings['unit']);
  Call('convert_units', '{"units": "in"}');
  Call('editor_scene');
  AssertEquals('the unit after a conversion', 'in', Answer.Strings['unit']);
  Call('undo');
  Call('editor_scene');
  Points := Answer.Arrays['points'];
  Edges := Answer.Arrays['edges'];
  Pieces := Answer.Arrays['pieces'];

  Point := Points.Objects[2];
  AssertEquals('point name', 'C', Point.Strings['name']);
  AssertEquals('point id', IdC, Point.Integers['id']);
  AssertNear('point x', 100, Point.Floats['x'], TOLERANCE);
  AssertNear('point y', 100, Point.Floats['y'], TOLERANCE);
  AssertEquals('point state', 'valid', Point.Strings['state']);
  AssertFalse('point locked', Point.Booleans['locked']);
  AssertTrue('not a copy', Point.Nulls['copyOf']);

  Edge := Edges.Objects[0];
  AssertEquals('edge role', 'outline', Edge.Strings['role']);
  Line := Edge.Arrays['line'];
  AssertEquals('a line is its two ends, x and y', 4, Line.Count);
  AssertNear('starts at A', 0, Line.Floats[0], TOLERANCE);
  AssertNear('ends at B', 100, Line.Floats[2], TOLERANCE);
  AssertFalse('no other edge on it', Assigned(Edge.Find('slot')));

  AssertEquals('piece name', 'Flap', Pieces.Objects[0].Strings['name']);
  AssertTrue('cut line round the square', Pieces.Objects[0].Arrays['cutLine'].Count >= 8);
  AssertTrue('piece fill', Pieces.Objects[0].Strings['fillStyle'] <> '');
end;

procedure TTestEditorServer.TestSceneOfEmptyPattern;
begin
  Call('editor_scene');
  AssertEquals('no points', 0, Answer.Arrays['points'].Count);
  AssertEquals('no edges', 0, Answer.Arrays['edges'].Count);
  AssertEquals('no pieces', 0, Answer.Arrays['pieces'].Count);
end;

procedure TTestEditorServer.TestSnapToPoint;
var
  IdB: integer;
begin
  AddSquare;
  IdB := IdOf('B');
  Call('editor_snap', '{"x": 100.5, "y": 0.5, "radius": 2}');
  AssertEquals('kind', 'point', Answer.Strings['kind']);
  AssertNear('at B', 100, Answer.Floats['x'], TOLERANCE);
  AssertEquals('works from B', IdB, Answer.Arrays['objects'].Integers[0]);
  AssertTrue('described', Pos('B', Answer.Strings['description']) > 0);
end;

procedure TTestEditorServer.TestSnapToEdge;
begin
  AddSquare;
  Call('editor_snap', '{"x": 50, "y": 1, "radius": 2}');
  AssertEquals('kind', 'edge', Answer.Strings['kind']);
  AssertNear('on the edge', 0, Answer.Floats['y'], 0.1);
  AssertEquals('one edge', 1, Answer.Arrays['objects'].Count);
end;

procedure TTestEditorServer.TestSnapFree;
begin
  AddSquare;
  Call('editor_snap', '{"x": 300, "y": 250, "radius": 2}');
  AssertEquals('kind', 'free', Answer.Strings['kind']);
  AssertNear('where clicked', 300, Answer.Floats['x'], TOLERANCE);
  AssertNear('where clicked down', 250, Answer.Floats['y'], TOLERANCE);
end;

procedure TTestEditorServer.TestObjectsAt;
var
  Objects: TJSONArray;
  IdB, IdFlap: integer;
begin
  AddSquare;
  IdB := IdOf('B');
  IdFlap := IdOf('Flap');
  Call('editor_objects_at', '{"x": 99.5, "y": 0, "pointRadius": 2, "edgeRadius": 2}');
  Objects := Answer.Arrays['objects'];
  AssertTrue('point, edges and piece', Objects.Count >= 3);
  AssertEquals('the point first', IdB, Objects.Integers[0]);
  Call('editor_objects_at', '{"x": 50, "y": 50, "pointRadius": 2, "edgeRadius": 2}');
  AssertEquals('inside, only the piece', 1, Answer.Arrays['objects'].Count);
  AssertEquals('the piece', IdFlap, Answer.Arrays['objects'].Integers[0]);
end;

procedure TTestEditorServer.TestSelectionGoneByUndo;
var
  IdA, IdGone: integer;
  Selection: string;
begin
  AddSquare;
  IdA := IdOf('A');
  Call('add_point', '{"type": "freePoint", "name": "Gone", "x": 200, "y": 0}');
  IdGone := IdOf('Gone');
  Call('undo');
  Selection := '"selection": [' + IntToStr(IdA) + ', ' + IntToStr(IdGone) + ', "Gone"]';
  Call('editor_objects_at', '{"x": 99.5, "y": 0, "pointRadius": 2, "edgeRadius": 2, ' + Selection + '}');
  AssertEquals('found what is there', IdOf('B'), Answer.Arrays['objects'].Integers[0]);
  Call('editor_label_keys', '{' + Selection + '}');
  AssertTrue('labels', Answer.Arrays['objects'].Count > 0);
  Call('editor_handles', '{' + Selection + '}');
  AssertEquals('no handles', 0, Answer.Arrays['handles'].Count);
  Call('editor_bounds', '{"ids": [' + IntToStr(IdA) + ', ' + IntToStr(IdGone) + ']}');
  AssertTrue('round what is there', Answer.Find('bounds').JSONType = jtArray);
  Call('editor_garment_marks', '{' + Selection + '}');
  Answer;
  // Deleting it is an edit, which says it is gone
  Call('editor_delete', '{"selection": [' + IntToStr(IdGone) + ']}');
  AssertEquals(RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestObjectsInBox;
begin
  AddSquare;
  Call('editor_objects_in_box', '{"minX": -1, "minY": -1, "maxX": 101, "maxY": 1}');
  // A and B, and the edge between them
  AssertEquals('top side', 3, Answer.Arrays['objects'].Count);
  Call('editor_objects_in_box', '{"minX": -1, "minY": -1, "maxX": 101, "maxY": 101}');
  AssertEquals('all but the piece, whose allowance lies outside', 8, Answer.Arrays['objects'].Count);
  Call('editor_objects_in_box', '{"minX": -100, "minY": -100, "maxX": 200, "maxY": 200}');
  AssertEquals('everything', 9, Answer.Arrays['objects'].Count);
end;

// The first ID the last tool click selected
function TTestEditorServer.Selected: integer;
begin
  if Answer.Nulls['select'] or (Answer.Arrays['select'].Count = 0) then
    Fail('Nothing selected: ' + FReply.AsJSON);
  Result := Answer.Arrays['select'].Integers[0];
end;

procedure TTestEditorServer.TestAddPointOnEdge;
var
  Id: integer;
begin
  AddSquare;
  Call('editor_tool_click', '{"tool": "point", "x": 40, "y": 0.5, "radius": 2}');
  AssertTrue('made', Answer.Booleans['done']);
  Id := Selected;
  Call('get_object', '{"id": ' + IntToStr(Id) + '}');
  AssertNear('on the edge', 0, Answer.Floats['y'], 0.1);
  AssertEquals('a point along the edge', 'alongEdgePoint', Answer.Strings['type']);
  Call('editor_changes');
  AssertEquals('its step', 'Add point', Answer.Strings['undo']);
  Call('undo');
  Call('get_object', '{"id": ' + IntToStr(Id) + '}');
  AssertEquals('undone in one step', RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestAddPointOnExistingPoint;
var
  IdD: integer;
begin
  AddSquare;
  IdD := IdOf('D');
  Call('editor_tool_click', '{"tool": "point", "x": 0.5, "y": 99.5, "radius": 2}');
  AssertFalse('no change', Answer.Booleans['done']);
  AssertEquals('D selected', IdD, Selected);
  Call('editor_scene');
  AssertEquals('no point added', 4, Answer.Arrays['points'].Count);
  // The last step is still the piece
  Call('undo');
  Call('editor_scene');
  AssertEquals('undo took the piece', 0, Answer.Arrays['pieces'].Count);
end;

procedure TTestEditorServer.TestLineTool;
var
  Line: integer;
begin
  Call('editor_tool_click', '{"tool": "line", "x": 0, "y": 0, "radius": 2}');
  AssertTrue('a first click', Answer.Booleans['started']);
  AssertFalse('no change yet', Answer.Booleans['done']);
  Call('editor_scene');
  AssertEquals('no point yet', 0, Answer.Arrays['points'].Count);
  Call('editor_tool_click', '{"tool": "line", "x": 100, "y": 0, "radius": 2, "start": {"x": 0, "y": 0, "radius": 2}}');
  AssertTrue('made', Answer.Booleans['done']);
  Line := Selected;
  AssertNear('the next starts at its end', 100, Answer.Objects['end'].Floats['x'], TOLERANCE);
  Call('get_object', '{"id": ' + IntToStr(Line) + '}');
  AssertEquals('a line', 'line', Answer.Strings['type']);
  AssertEquals('outline by default', 'outline', Answer.Strings['role']);
  AssertNear('its length', 100, Answer.Floats['length'], TOLERANCE);
  Call('editor_changes');
  AssertEquals('one step with its points', 'Add line', Answer.Strings['undo']);
  // Carrying on from the end, which is now a point
  Call('editor_tool_click', '{"tool": "line", "x": 100, "y": 50, "radius": 2, "start": {"x": 100, "y": 0, "radius": 2}, ' +
    '"role": "construction"}');
  Call('editor_scene');
  AssertEquals('three points, the end shared', 3, Answer.Arrays['points'].Count);
  // In drawing order, construction lines under the rest
  AssertEquals('the role given', 'construction', Answer.Arrays['edges'].Objects[0].Strings['role']);
  Call('undo');
  Call('undo');
  Call('editor_scene');
  AssertEquals('each line one step', 0, Answer.Arrays['points'].Count);
end;

procedure TTestEditorServer.TestLineTooShortIgnored;
begin
  Call('editor_tool_click', '{"tool": "line", "x": 10, "y": 10, "radius": 2, "start": {"x": 10, "y": 10.01, "radius": 2}}');
  AssertFalse('nothing', Answer.Booleans['done']);
  AssertEquals('and nothing said', '', Answer.Strings['message']);
end;

procedure TTestEditorServer.TestLineToolChainsOffsets;
var
  First, Second: integer;

// The offset point with this ID, across and down from its base
  function OffsetOf(Id: integer): TOffsetPoint;
  begin
    Result := TOffsetPoint(FServer.Document.Pattern.FindNode(IntToStr(Id)));
    AssertTrue('an offset point', Result is TOffsetPoint);
    AssertTrue('across and down', Result.Mode = omCartesian);
  end;

begin
  Call('editor_tool_click', '{"tool": "line", "x": 40, "y": 70, "radius": 2, "start": {"x": 0, "y": 0, "radius": 2}}');
  AssertTrue('made', Answer.Booleans['done']);
  Call('editor_scene');
  AssertEquals('both ends made', 2, Answer.Arrays['points'].Count);
  First := Answer.Arrays['points'].Objects[0].Integers['id'];
  Second := Answer.Arrays['points'].Objects[1].Integers['id'];
  Call('get_object', '{"id": ' + IntToStr(First) + '}');
  AssertEquals('the first point is free', 'freePoint', Answer.Strings['type']);
  AssertEquals('the end from the start', IntToStr(First), OffsetOf(Second).Base);
  Call('get_object', '{"id": ' + IntToStr(Second) + '}');
  AssertNear('across', 40, Answer.Floats['x'], TOLERANCE);
  AssertNear('down', 70, Answer.Floats['y'], TOLERANCE);
  // What the next click would make, then making it from the end
  Call('editor_tool_snap', '{"tool": "line", "x": 90, "y": 75, "radius": 2, "start": {"x": 40, "y": 70, "radius": 2}}');
  AssertEquals('offset', 'offset', Answer.Strings['kind']);
  AssertTrue('says so', Pos('across', Answer.Strings['description']) > 0);
  Call('editor_tool_click', '{"tool": "line", "x": 90, "y": 75, "radius": 2, "start": {"x": 40, "y": 70, "radius": 2}}');
  Call('editor_scene');
  AssertEquals('from the last end', IntToStr(Second), OffsetOf(Answer.Arrays['points'].Objects[2].Integers['id']).Base);
  // Closing on the first point makes no point
  Call('editor_tool_click', '{"tool": "line", "x": 0.5, "y": 0.5, "radius": 2, "start": {"x": 90, "y": 75, "radius": 2}}');
  AssertTrue('closed', Answer.Booleans['done']);
  Call('editor_scene');
  AssertEquals('three points', 3, Answer.Arrays['points'].Count);
  AssertEquals('three lines', 3, Answer.Arrays['edges'].Count);
end;

procedure TTestEditorServer.TestRebasePoint;
var
  Point: TDraftObject;
begin
  AddSquare;
  Call('add_variable', '{"name": "size", "formula": "20"}');
  Call('add_point', '{"type": "offsetPoint", "name": "P", "base": "A", "mode": "cartesian", "dx": "10", ' +
    '"dy": "#size"}');
  Call('editor_rebase_snap', '{"from": {"x": 10, "y": 20.5, "radius": 2}, "x": 99.5, "y": 0.5, "radius": 2}');
  AssertEquals('onto a point', 'point', Answer.Strings['kind']);
  AssertEquals('says what it will do', Format(rsToolRebaseOffset, ['P', 'B']), Answer.Strings['description']);
  AssertNear('drawn from the point', 20, Answer.Objects['from'].Floats['y'], TOLERANCE);
  Call('editor_rebase_point', '{"from": {"x": 10, "y": 20.5, "radius": 2}, "x": 99.5, "y": 0.5, "radius": 2}');
  AssertTrue('done', Answer.Booleans['done']);
  AssertTrue('its formula became a number', Pos('numbers', Answer.Strings['message']) > 0);
  Point := FServer.Document.Pattern.FindObject('P');
  AssertTrue('an offset', (Point is TOffsetPoint) and (TOffsetPoint(Point).Mode = omCartesian));
  AssertEquals('from B', IntToStr(IdOf('B')), TOffsetPoint(Point).Base);
  Call('get_object', '{"name": "P"}');
  AssertNear('where it was', 10, Answer.Floats['x'], TOLERANCE);
  AssertNear('where it was', 20, Answer.Floats['y'], TOLERANCE);
  Call('editor_changes');
  AssertEquals('one step', 'Change point type', Answer.Strings['undo']);
  Call('undo');
  Answer;
  AssertEquals('undone', IntToStr(IdOf('A')), TOffsetPoint(FServer.Document.Pattern.FindObject('P')).Base);
  // Dropped in open space it is free
  Call('editor_rebase_snap', '{"from": {"x": 10, "y": 20, "radius": 2}, "x": 300, "y": 300, "radius": 2}');
  AssertEquals(Format(rsToolRebaseFree, ['P']), Answer.Strings['description']);
  Call('editor_rebase_point', '{"from": {"x": 10, "y": 20, "radius": 2}, "x": 300, "y": 300, "radius": 2}');
  AssertTrue('freed', Answer.Booleans['done']);
  AssertTrue('a free point', FServer.Document.Pattern.FindObject('P') is TFreePoint);
  Call('get_object', '{"name": "P"}');
  AssertNear('still there', 20, Answer.Floats['y'], TOLERANCE);
end;

procedure TTestEditorServer.TestRebaseRefused;
begin
  AddSquare;
  Call('add_variable', '{"name": "size", "formula": "20"}');
  Call('add_point', '{"type": "offsetPoint", "name": "P", "base": "A", "mode": "cartesian", "dx": "10", ' +
    '"dy": "#size"}');
  Call('add_point', '{"type": "offsetPoint", "name": "R", "base": "P", "mode": "cartesian", "dx": "5", "dy": "5"}');
  Call('add_point', '{"type": "alongEdgePoint", "name": "Q", "edge": "Line_A_B", "from": "start", "mode": "length", ' +
    '"value": "50"}');
  Answer;
  // Onto an edge
  Call('editor_rebase_snap', '{"from": {"x": 10, "y": 20, "radius": 2}, "x": 30, "y": 100.5, "radius": 2}');
  AssertEquals(Format(rsToolRebaseOnPoint, ['P']), Answer.Strings['description']);
  Call('editor_rebase_point', '{"from": {"x": 10, "y": 20, "radius": 2}, "x": 30, "y": 100.5, "radius": 2}');
  AssertFalse('not on an edge', Answer.Booleans['done']);
  AssertEquals('says why', Format(rsToolRebaseOnPoint, ['P']), Answer.Strings['message']);
  // Back onto itself: nothing, quietly
  Call('editor_rebase_point', '{"from": {"x": 10, "y": 20, "radius": 2}, "x": 10.5, "y": 20, "radius": 2}');
  AssertFalse('nothing', Answer.Booleans['done']);
  AssertEquals('nothing said', '', Answer.Strings['message']);
  // Onto a point placed from it
  Call('editor_rebase_point', '{"from": {"x": 10, "y": 20, "radius": 2}, "x": 15, "y": 25, "radius": 2}');
  AssertFalse('no loop', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['message'] <> '');
  // Only free and offset points
  Call('editor_rebase_snap', '{"from": {"x": 50, "y": 0, "radius": 2}, "x": 300, "y": 300, "radius": 2}');
  AssertEquals(Format(rsToolRebaseNotFreeOrOffset, ['Q']), Answer.Strings['description']);
  Call('editor_rebase_point', '{"from": {"x": 50, "y": 0, "radius": 2}, "x": 300, "y": 300, "radius": 2}');
  AssertFalse('not along an edge', Answer.Booleans['done']);
  // From open space there is nothing to drag
  Call('editor_rebase_snap', '{"from": {"x": 300, "y": 300, "radius": 2}, "x": 0, "y": 0, "radius": 2}');
  AssertTrue('no point', Answer.Nulls['from']);
  Call('editor_rebase_point', '{"from": {"x": 300, "y": 300, "radius": 2}, "x": 0, "y": 0, "radius": 2}');
  AssertFalse('nothing', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('no step made', 'Add alongEdgePoint', Answer.Strings['undo']);
end;

procedure TTestEditorServer.TestCurveToolCarriesOn;
var
  Curve: integer;
begin
  Call('editor_tool_click', '{"tool": "curve", "x": 100, "y": 0, "radius": 2, "start": {"x": 0, "y": 0, "radius": 2}}');
  Curve := Answer.Integers['curve'];
  Call('editor_tool_click', '{"tool": "curve", "x": 200, "y": 50, "radius": 2, "start": {"x": 100, "y": 0, "radius": 2}, ' +
    '"extend": ' + IntToStr(Curve) + '}');
  AssertTrue('carried on', Answer.Booleans['done']);
  AssertEquals('the same path', Curve, Answer.Integers['curve']);
  Call('editor_scene');
  AssertEquals('one edge', 1, Answer.Arrays['edges'].Count);
  Call('editor_changes');
  AssertEquals('its step', 'Carry curve on', Answer.Strings['undo']);
end;

procedure TTestEditorServer.TestShapeTools;
var
  Shape: integer;
begin
  Call('editor_tool_click', '{"tool": "circle", "x": 50, "y": 50, "radius": 2}');
  AssertTrue('a first click', Answer.Booleans['started']);
  AssertTrue('asks for the rim', Answer.Strings['message'] <> '');
  Call('editor_tool_snap', '{"tool": "circle", "x": 80, "y": 50, "radius": 2, "start": {"x": 50, "y": 50, "radius": 2}}');
  AssertTrue('the radius while choosing', Pos('30', Answer.Strings['description']) > 0);
  AssertNear('where it started', 50, Answer.Objects['start'].Floats['x'], TOLERANCE);
  Call('editor_tool_click', '{"tool": "circle", "x": 80, "y": 50, "radius": 2, "start": {"x": 50, "y": 50, "radius": 2}}');
  Shape := Selected;
  Call('get_object', '{"id": ' + IntToStr(Shape) + '}');
  AssertEquals('a circle', 'circle', Answer.Strings['type']);
  Call('editor_tool_click', '{"tool": "rectangle", "x": 300, "y": 200, "radius": 2, "start": {"x": 200, "y": 150, "radius": 2}}');
  AssertTrue('made', Answer.Booleans['done']);
  AssertEquals('four edges selected', 4, Answer.Arrays['select'].Count);
end;

procedure TTestEditorServer.TestPieceTool;
var
  Flap: integer;
begin
  AddSquare;
  Flap := IdOf('Flap');
  Call('editor_tool_click', '{"tool": "piece", "x": 50, "y": 50, "radius": 2}');
  AssertFalse('there already', Answer.Booleans['done']);
  AssertTrue('says so', Pos('Flap', Answer.Strings['message']) > 0);
  AssertEquals('and selects it', Flap, Selected);
  Call('undo');
  Call('editor_tool_click', '{"tool": "piece", "x": 50, "y": 50, "radius": 2}');
  AssertTrue('made again', Answer.Booleans['done']);
  Call('editor_tool_click', '{"tool": "piece", "x": 500, "y": 500, "radius": 2}');
  AssertFalse('no outline there', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['message'] <> '');
end;

procedure TTestEditorServer.TestNotchTool;
begin
  AddSquare;
  Call('editor_tool_click', '{"tool": "notch", "x": 50, "y": 0, "radius": 2}');
  AssertTrue('added', Answer.Booleans['done']);
  Call('editor_scene');
  AssertEquals('drawn: one segment', 4, Answer.Arrays['pieces'].Objects[0].Arrays['notches'].Count);
  Call('editor_changes');
  AssertEquals('its step', 'Add notch', Answer.Strings['undo']);
  Call('editor_tool_click', '{"tool": "notch", "x": 50, "y": 0.5, "radius": 2}');
  AssertTrue('removed', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Remove notch', Answer.Strings['undo']);
  Call('editor_tool_click', '{"tool": "notch", "x": 50, "y": 50, "radius": 2}');
  AssertFalse('no seam line there', Answer.Booleans['done']);
  AssertTrue('says so', Answer.Strings['message'] <> '');
end;

procedure TTestEditorServer.TestSceneMarks;
begin
  AddSquare;
  Call('set_marker', '{"name": "A", "marker": "hole", "size": 6}');
  Answer;
  Call('editor_scene');
  AssertTrue('the grainline drawn', Answer.Arrays['pieces'].Objects[0].Arrays['marks'].Count >= 4);
  AssertEquals('one marker', 1, Answer.Arrays['markers'].Count);
  AssertTrue('its strokes', Answer.Arrays['markers'].Objects[0].Arrays['strokes'].Count >= 8);
end;

procedure TTestEditorServer.TestStandaloneMeasurements;
const
  MEASURE_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"Sample",' +
    '"measurements":[{"key":"waist","value":720,"description":"Waist"}]}';
var
  Params: TJSONObject;
begin
  AddSquare;
  Params := TJSONObject.Create(['text', MEASURE_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
    AssertEquals('Sample', Answer.Objects['set'].Strings['name']);
    AssertEquals(1, Answer.Objects['set'].Arrays['measurements'].Count);
  finally
    FreeAndNil(Params);
  end;
  Call('measurements_open', '{"text":"invalid"}');
  AssertEquals(RPC_REFUSED, ErrorCode);
  Call('measurements_state');
  AssertEquals('old set remains available', 'Sample', Answer.Objects['set'].Strings['name']);
  Call('get_object', '{"name":"Flap"}');
  AssertEquals('pattern still open', 'Flap', Answer.Strings['name']);
end;

procedure TTestEditorServer.TestMeasurementsSaveCompletion;
var
  Saved: string;
begin
  Call('measurements_set_name', '{"text":"First"}');
  Call('measurements_text');
  Saved := Answer.Strings['text'];
  Call('measurements_state');
  AssertTrue('taking a snapshot does not save', Answer.Booleans['modified']);
  Call('measurements_set_notes', '{"text":"a later edit"}');
  Call('measurements_saved', '{"text":"' + StringToJSONString(Saved) + '"}');
  AssertTrue('later edit still unsaved', Answer.Booleans['modified']);
  Call('measurements_undo');
  AssertFalse('undo reached the text written', Answer.Booleans['modified']);
  Call('measurements_open', '{"text":"' + StringToJSONString(Saved) + '"}');
  Call('measurements_mark_unsaved');
  AssertTrue('recovered set is unsaved', Answer.Booleans['modified']);
  AssertFalse('no edit added to history', Answer.Booleans['canUndo']);
end;

procedure TTestEditorServer.TestMeasurementsTable;
const
  SIZED_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"Sizes","sizes":["S","M"],' +
    '"measurements":[{"key":"waist","values":[700,742.5],"description":"Waist"},' +
    '{"key":"hip","values":[960,null],"description":""}]}';
var
  Params: TJSONObject;
  Rows: TJSONArray;
begin
  Call('measurements_state');
  AssertEquals('mm before anything is asked', 'mm', Answer.Strings['unit']);
  AssertEquals('no rows before a set is opened', 0, Answer.Arrays['rows'].Count);
  Params := TJSONObject.Create(['text', SIZED_TEXT, 'unit', 'cm']);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  AssertEquals('cm', Answer.Strings['unit']);
  AssertEquals('a column a size', 2, Answer.Arrays['sizes'].Count);
  AssertEquals('M', Answer.Arrays['sizes'].Strings[1]);
  Rows := Answer.Arrays['rows'];
  AssertEquals(2, Rows.Count);
  AssertEquals('waist', Rows.Objects[0].Strings['key']);
  AssertEquals('in cm', '70', Rows.Objects[0].Arrays['values'].Strings[0]);
  AssertEquals('74.25', Rows.Objects[0].Arrays['values'].Strings[1]);
  AssertEquals('Waist', Rows.Objects[0].Strings['description']);
  AssertEquals('no value for a size', '', Rows.Objects[1].Arrays['values'].Strings[1]);
  Call('measurements_state', '{"unit":"in"}');
  AssertEquals('in inches', '27.5591', Answer.Arrays['rows'].Objects[0].Arrays['values'].Strings[0]);
  Call('measurements_open', '{"text":"{}","unit":"feet"}');
  AssertEquals('a bad unit is refused', RPC_INVALID_PARAMS, ErrorCode);
  Call('measurements_state');
  AssertEquals('and the set stays', 'Sizes', Answer.Objects['set'].Strings['name']);
end;

procedure TTestEditorServer.TestMeasurementsEdits;
const
  SET_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"Two",' +
    '"measurements":[{"key":"waist","value":700,"description":"Waist"},{"key":"hip","value":960}]}';
var
  Params: TJSONObject;
  Added: string;

  function Keys: string;
  var
    Index: integer;
  begin
    Result := '';
    for Index := 0 to Answer.Arrays['rows'].Count - 1 do
      Result := Result + Answer.Arrays['rows'].Objects[Index].Strings['key'] + ' ';
    Result := Trim(Result);
  end;

begin
  Params := TJSONObject.Create(['text', SET_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  AssertFalse('nothing to undo after opening', Answer.Booleans['canUndo']);
  Call('measurements_set', '{"key":"waist","column":"value","text":"72","unit":"cm"}');
  AssertTrue(Answer.Strings['reason'], Answer.Booleans['done']);
  AssertEquals('shown in the unit', '72', Answer.Arrays['rows'].Objects[0].Arrays['values'].Strings[0]);
  AssertTrue('modified', Answer.Booleans['modified']);
  AssertEquals('Change value', Answer.Strings['undo']);
  Call('measurements_set', '{"key":"waist","column":"value","text":"wide"}');
  AssertFalse('not a number', Answer.Booleans['done']);
  AssertEquals('A value must be a number, such as 82.5', Answer.Strings['reason']);
  Call('measurements_set', '{"key":"waist","column":"key","text":"hip"}');
  AssertFalse('a key in use', Answer.Booleans['done']);
  Call('measurements_set', '{"key":"waist","column":"key","text":" waist_circumference "}');
  AssertTrue(Answer.Strings['reason'], Answer.Booleans['done']);
  AssertEquals('renamed, trimmed', 'waist_circumference', Answer.Strings['key']);
  Call('measurements_set', '{"key":"hip","column":"description","text":"Hip"}');
  AssertEquals('Hip', Answer.Arrays['rows'].Objects[1].Strings['description']);
  Call('measurements_add');
  Added := Answer.Strings['key'];
  AssertEquals('added at the end', 'waist_circumference hip ' + Added, Keys);
  Call('measurements_move', '{"key":"' + Added + '","index":0}');
  AssertEquals('moved to the top', Added + ' waist_circumference hip', Keys);
  Call('measurements_move', '{"key":"hip","index":3}');
  AssertEquals('past the end refused', RPC_INVALID_PARAMS, ErrorCode);
  Call('measurements_delete', '{"key":"' + Added + '"}');
  AssertEquals('deleted', 'waist_circumference hip', Keys);
  Call('measurements_delete', '{"key":"chest"}');
  AssertEquals('no such key', RPC_REFUSED, ErrorCode);
  Call('measurements_set', '{"key":"hip","column":"value","size":1,"text":"9"}');
  AssertEquals('no such size', RPC_INVALID_PARAMS, ErrorCode);
  // Back through every step: delete, move, add, description, rename, value
  Call('measurements_undo');
  AssertEquals('Move measurement', Answer.Strings['undo']);
  Call('measurements_undo');
  Call('measurements_undo');
  Call('measurements_undo');
  Call('measurements_undo');
  AssertEquals('waist hip', Keys);
  Call('measurements_undo');
  AssertEquals('the first value back', '700', Answer.Arrays['rows'].Objects[0].Arrays['values'].Strings[0]);
  AssertFalse('all undone', Answer.Booleans['canUndo']);
  Call('measurements_undo');
  AssertEquals('nothing left to undo', RPC_REFUSED, ErrorCode);
  Call('measurements_redo');
  AssertEquals('the value redone, in mm', '720', Answer.Arrays['rows'].Objects[0].Arrays['values'].Strings[0]);
end;

procedure TTestEditorServer.TestMeasurementsSizes;
const
  SET_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"One",' +
    '"measurements":[{"key":"waist","value":700}]}';
var
  Params: TJSONObject;

  function Sizes: string;
  var
    Index: integer;
  begin
    Result := '';
    for Index := 0 to Answer.Arrays['sizes'].Count - 1 do
      Result := Result + Answer.Arrays['sizes'].Strings[Index] + ' ';
    Result := Trim(Result);
  end;

  function Values: string;
  var
    Index: integer;
    Row: TJSONArray;
  begin
    Result := '';
    Row := Answer.Arrays['rows'].Objects[0].Arrays['values'];
    for Index := 0 to Row.Count - 1 do
      Result := Result + Row.Strings[Index] + ' ';
    Result := Trim(Result);
  end;

begin
  Params := TJSONObject.Create(['text', SET_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  // The first size takes the set's values
  Call('measurements_add_size', '{"name":"M"}');
  AssertEquals('M', Sizes);
  AssertEquals('the value kept', '700', Values);
  AssertEquals('Add size', Answer.Strings['undo']);
  Call('measurements_add_size', '{"name":"L"}');
  AssertEquals('M L', Sizes);
  AssertEquals('the new size empty', '700', Values);
  Call('measurements_add_size', '{"name":"m"}');
  AssertEquals('a name in use, ignoring case', RPC_REFUSED, ErrorCode);
  Call('measurements_add_size', '{"name":""}');
  AssertEquals('no name', RPC_REFUSED, ErrorCode);
  AssertEquals('with the reason', 'A size needs a name', TJSONObject(FReply.Find('error')).Get('message', ''));
  Call('measurements_set', '{"key":"waist","column":"value","size":1,"text":"740"}');
  Call('measurements_rename_size', '{"size":0,"name":"Medium"}');
  AssertEquals('Medium L', Sizes);
  Call('measurements_rename_size', '{"size":1,"name":"Medium"}');
  AssertEquals('a name in use', RPC_REFUSED, ErrorCode);
  Call('measurements_rename_size', '{"size":2,"name":"XL"}');
  AssertEquals('no such size', RPC_INVALID_PARAMS, ErrorCode);
  Call('measurements_move_size', '{"size":1,"index":0}');
  AssertEquals('L Medium', Sizes);
  AssertEquals('the values move with it', '740 700', Values);
  AssertEquals('Move size', Answer.Strings['undo']);
  Call('measurements_move_size', '{"size":1,"index":2}');
  AssertEquals('past the end refused', RPC_INVALID_PARAMS, ErrorCode);
  Call('measurements_delete_size', '{"size":0}');
  AssertEquals('Medium', Sizes);
  AssertEquals('700', Values);
  Call('measurements_delete_size', '{"size":0}');
  AssertEquals('not the last size', RPC_REFUSED, ErrorCode);
  // Back through delete, move, rename, value and the two sizes added
  Call('measurements_undo');
  Call('measurements_undo');
  Call('measurements_undo');
  AssertEquals('M L', Sizes);
  Call('measurements_undo');
  Call('measurements_undo');
  Call('measurements_undo');
  AssertEquals('a set without sizes again', '', Sizes);
  AssertFalse('all undone', Answer.Booleans['canUndo']);
end;

procedure TTestEditorServer.TestMeasurementsNameAndNotes;
const
  SET_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"One","notes":"Taken in May",' +
    '"measurements":[{"key":"waist","value":700}]}';
var
  Params: TJSONObject;
begin
  Params := TJSONObject.Create(['text', SET_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  Call('measurements_set_name', '{"text":"One"}');
  AssertFalse('unchanged: no undo step', Answer.Booleans['canUndo']);
  AssertFalse('nor modified', Answer.Booleans['modified']);
  Call('measurements_set_name', '{"text":"Anna"}');
  AssertEquals('Anna', Answer.Objects['set'].Strings['name']);
  AssertEquals('Change name', Answer.Strings['undo']);
  AssertTrue('modified', Answer.Booleans['modified']);
  Call('measurements_set_notes', '{"text":"Taken in June"}');
  AssertEquals('Taken in June', Answer.Objects['set'].Strings['notes']);
  AssertEquals('Change notes', Answer.Strings['undo']);
  Call('measurements_set_notes', '{}');
  AssertEquals('text needed', RPC_INVALID_PARAMS, ErrorCode);
  Call('measurements_undo');
  AssertEquals('Taken in May', Answer.Objects['set'].Strings['notes']);
  Call('measurements_undo');
  AssertEquals('One', Answer.Objects['set'].Strings['name']);
  AssertFalse('all undone', Answer.Booleans['canUndo']);
end;

procedure TTestEditorServer.TestMeasurementsCatalogue;
const
  SET_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"One",' +
    '"measurements":[{"key":"head_length","value":100}]}';
var
  Params: TJSONObject;
  Text, Reason: string;

  function Listed: string;
  var
    Index: integer;
  begin
    Result := '';
    for Index := 0 to Answer.Arrays['entries'].Count - 1 do
      Result := Result + Answer.Arrays['entries'].Objects[Index].Strings['key'] + ' ';
    Result := Trim(Result);
  end;

begin
  Params := TJSONObject.Create(['text', SET_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  // Without a catalogue, nothing is listed and nothing is out of range
  Call('measurements_catalogue_list');
  AssertEquals('', Listed);
  AssertTrue(Reason, ReadTextFile(TAppPaths.CatalogueFile, Text, Reason));
  Params := TJSONObject.Create(['text', Text]);
  try
    Call('measurements_catalogue', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  AssertTrue('the catalogue loaded', Answer.Integers['count'] > 0);
  Call('measurements_catalogue', '{"text":"{}"}');
  AssertEquals('not a catalogue', RPC_REFUSED, ErrorCode);
  Call('measurements_catalogue_list', '{"group":"head"}');
  AssertEquals('without the one the set has', 'head_circumference head_width', Listed);
  Call('measurements_catalogue_list', '{"search":"WAIST, BACK ARC"}');
  AssertEquals('by name, ignoring case', 'waist_back_arc', Listed);
  Call('measurements_catalogue_entry', '{"key":"waist_circumference","unit":"cm"}');
  AssertTrue(Answer.Booleans['found']);
  AssertEquals('Waist circumference', Answer.Strings['name']);
  AssertEquals('in the unit', '55', Answer.Strings['rangeMin']);
  AssertEquals('150', Answer.Strings['rangeMax']);
  Call('measurements_catalogue_entry', '{"key":"tail_length"}');
  AssertFalse('no such entry', Answer.Booleans['found']);
  Call('measurements_add_known', '{"key":"waist_circumference"}');
  AssertEquals('waist_circumference', Answer.Strings['key']);
  AssertEquals('with its description', 'Round the natural waist.',
    Answer.Arrays['rows'].Objects[1].Strings['description']);
  AssertEquals('Add measurement', Answer.Strings['undo']);
  Call('measurements_add_known', '{"key":"waist_circumference"}');
  AssertEquals('one the set has', RPC_REFUSED, ErrorCode);
  Call('measurements_add_known', '{"key":"tail_length"}');
  AssertEquals('not in the catalogue', RPC_REFUSED, ErrorCode);
  // Outside the typical range only warns: the value is kept
  Call('measurements_set', '{"key":"waist_circumference","column":"value","text":"300"}');
  AssertTrue(Answer.Booleans['done']);
  AssertEquals('@waist_circumference is outside the usual 550 to 1500 mm; it is kept, in case that is right',
    Answer.Strings['warning']);
  AssertTrue('flagged', Answer.Arrays['rows'].Objects[1].Arrays['outside'].Booleans[0]);
  Call('measurements_set', '{"key":"waist_circumference","column":"value","text":"700"}');
  AssertEquals('inside it', '', Answer.Strings['warning']);
  AssertFalse(Answer.Arrays['rows'].Objects[1].Arrays['outside'].Booleans[0]);
end;

procedure TTestEditorServer.TestMeasurementsFigure;
const
  SET_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"One",' +
    '"measurements":[{"key":"height","value":1700}]}';
  Width = 430;
  Height = 300;
var
  Params: TJSONObject;
  Text, Reason, Svg: string;
  Entry: TCatalogueEntry;
  Layout: TFigureLayout;
  Spot: TVec2;
  Catalogue: TCatalogue;
begin
  Params := TJSONObject.Create(['text', SET_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  Call('measurements_figure', '{"width":430,"height":300}');
  AssertTrue('a figure before the catalogue', Pos('<svg', Answer.Strings['svg']) = 1);
  AssertEquals('with nothing drawn on it', 0, Pos('<polygon', Answer.Strings['svg']));
  AssertTrue(Reason, ReadTextFile(TAppPaths.CatalogueFile, Text, Reason));
  Params := TJSONObject.Create(['text', Text]);
  try
    Call('measurements_catalogue', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  Call('measurements_figure', '{"width":430,"height":300,"highlight":"waist_circumference"}');
  Svg := Answer.Strings['svg'];
  AssertTrue('the outlines', Pos('<polygon', Svg) > 0);
  AssertTrue('the views named', Pos('>Front</text>', Svg) > 0);
  AssertTrue('the set''s measurement drawn faintly', Pos('stroke="#7896BE"', Svg) > 0);
  AssertTrue('the highlight, though not in the set', Pos('stroke="#C8322A"', Svg) > 0);
  Call('measurements_figure', '{"width":430}');
  AssertEquals('a size needed', RPC_INVALID_PARAMS, ErrorCode);
  // A point on the height's line picks it; one off the figure picks nothing
  Catalogue := TCatalogue.Create;
  try
    AssertTrue(Reason, Catalogue.LoadFromText(Text, Reason));
    Entry := Catalogue.Find('height');
    // As the figure lays itself out, with room for the captions under it
    Layout := LayoutFigures(Width, Height - 19);
    Spot := FigureToScreen(Layout, Entry.View, Entry.Overlay[0]);
  finally
    FreeAndNil(Catalogue);
  end;
  Call('measurements_figure_at', Format('{"width":%d,"height":%d,"x":%s,"y":%s}', [Width, Height,
    FormatJSONFloat(Spot.X), FormatJSONFloat(Spot.Y)]));
  AssertEquals('height', Answer.Strings['key']);
  Call('measurements_figure_at', '{"width":430,"height":300,"x":1,"y":1}');
  AssertEquals('', Answer.Strings['key']);
end;

procedure TTestEditorServer.TestMeasurementsCheckPattern;
const
  SET_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"Sizes","sizes":["S","M"],' +
    '"measurements":[{"key":"waist","values":[700,null]},{"key":"hip","values":[900,950]}]}';
var
  Params: TJSONObject;
  Pattern: TPattern;
  Keys: TMeasurementSet;
  PatternText, Text, Reason: string;

  function MissingText: string;
  var
    Index: integer;
    Item: TJSONObject;
  begin
    Result := '';
    for Index := 0 to Answer.Arrays['missing'].Count - 1 do
    begin
      Item := Answer.Arrays['missing'].Objects[Index];
      Result := Result + Item.Strings['key'];
      if Item.Arrays['sizes'].Count > 0 then
        Result := Result + ':' + Item.Arrays['sizes'].Strings[0];
      Result := Result + ' ';
    end;
    Result := Trim(Result);
  end;

begin
  // Its keys are known while the formulas are given, as a pattern drafted with them
  Keys := TMeasurementSet.Create;
  Pattern := TPattern.Create;
  try
    Keys.Add('waist', 1);
    Keys.Add('hip', 1);
    Keys.Add('waist_circumference', 1);
    Pattern.Measurements := Keys;
    Pattern.AddFreePoint('A', '@waist + @hip', '@waist_circumference');
    PatternText := SavePatternToText(Pattern);
  finally
    FreeAndNil(Pattern);
    FreeAndNil(Keys);
  end;
  Params := TJSONObject.Create(['text', SET_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  AssertEquals('not checking', '', Answer.Strings['pattern']);
  AssertEquals(0, Answer.Arrays['missing'].Count);
  Params := TJSONObject.Create(['name', 'skirt.sloper', 'text', PatternText]);
  try
    Call('measurements_check_pattern', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  AssertEquals('skirt.sloper', Answer.Strings['pattern']);
  AssertEquals('a size short, and a key the set lacks', 'waist:M waist_circumference', MissingText);
  AssertFalse('nothing to undo', Answer.Booleans['canUndo']);
  Call('measurements_check_pattern', '{"name":"notes.sloper","text":"{}"}');
  AssertEquals('not a pattern', RPC_REFUSED, ErrorCode);
  Call('measurements_state');
  AssertEquals('the check before stays', 'skirt.sloper', Answer.Strings['pattern']);
  // The catalogue gives the added key its description
  AssertTrue(Reason, ReadTextFile(TAppPaths.CatalogueFile, Text, Reason));
  Params := TJSONObject.Create(['text', Text]);
  try
    Call('measurements_catalogue', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  Call('measurements_add_missing', '{"key":"waist_circumference"}');
  AssertEquals('waist_circumference', Answer.Strings['key']);
  AssertEquals('Round the natural waist.', Answer.Arrays['rows'].Objects[2].Strings['description']);
  AssertEquals('now short of its values', 'waist:M waist_circumference:S', MissingText);
  Call('measurements_add_missing', '{"key":"waist"}');
  AssertEquals('a key the set has', RPC_REFUSED, ErrorCode);
  Call('measurements_stop_check');
  AssertEquals('', Answer.Strings['pattern']);
  AssertEquals(0, Answer.Arrays['missing'].Count);
end;

procedure TTestEditorServer.TestMeasurementsImportExport;
const
  SET_TEXT = '{"format":"measurements","version":1,"units":"mm","name":"Sizes","sizes":["40","42"],' +
    '"measurements":[{"key":"waist_circumference","values":[700,720]}]}';
  SMIS = '<?xml version="1.0" encoding="UTF-8"?><smis><version>0.3.4</version><read-only>false</read-only>' +
    '<notes>Fitted</notes><unit>cm</unit><pm_system>998</pm_system><personal><family-name/></personal>' +
    '<body-measurements><m name="waist_circ" value="82"/><m name="@my own" value="3"/></body-measurements></smis>';
var
  Params: TJSONObject;
  Text, Reason: string;
begin
  AssertTrue(Reason, ReadTextFile(TAppPaths.CatalogueFile, Text, Reason));
  Params := TJSONObject.Create(['text', Text]);
  try
    Call('measurements_catalogue', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  Params := TJSONObject.Create(['text', SET_TEXT]);
  try
    Call('measurements_open', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  // An individual file takes the size asked for; the set keeps its own
  Call('measurements_export', '{"kind":"smis","size":1}');
  Text := Answer.Strings['text'];
  AssertTrue(Text, Pos('name="waist_circ" value="720"', Text) > 0);
  AssertTrue('the size is noted', Answer.Arrays['notes'].Count > 0);
  Call('measurements_export', '{"kind":"vit"}');
  AssertTrue('the selected size', Pos('value="700"', Answer.Strings['text']) > 0);
  Call('measurements_export', '{"kind":"vst"}');
  AssertTrue(Pos('<vst>', Answer.Strings['text']) > 0);
  Call('measurements_export', '{"kind":"txt"}');
  AssertEquals('not a kind', RPC_INVALID_PARAMS, ErrorCode);
  Call('measurements_state');
  AssertFalse('exporting leaves the set', Answer.Booleans['modified']);
  Call('measurements_set', '{"key":"waist_circumference","column":"value","size":0,"text":"710"}');
  Params := TJSONObject.Create(['name', 'Sam.smis', 'text', SMIS, 'unit', 'cm']);
  try
    Call('measurements_import', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  AssertEquals('named after the file', 'Sam', Answer.Objects['set'].Strings['name']);
  AssertEquals('Fitted', Answer.Objects['set'].Strings['notes']);
  AssertEquals('waist_circumference', Answer.Arrays['rows'].Objects[0].Strings['key']);
  AssertEquals('in the unit', '82', Answer.Arrays['rows'].Objects[0].Arrays['values'].Strings[0]);
  AssertEquals(2, Answer.Objects['report'].Integers['count']);
  AssertEquals('waist_circ -> waist_circumference', Answer.Objects['report'].Arrays['translated'].Strings[0]);
  AssertEquals('one corrected', 1, Answer.Objects['report'].Arrays['corrected'].Count);
  AssertTrue('not saved', Answer.Booleans['modified']);
  AssertFalse('nothing to undo', Answer.Booleans['canUndo']);
  Call('measurements_import', '{"name":"bad.smis","text":"<smis>"}');
  AssertEquals('not a file that reads', RPC_REFUSED, ErrorCode);
  Reason := TJSONObject(FReply.Find('error')).Get('message', '');
  AssertTrue(Reason, Reason.StartsWith('Could not import bad.smis: '));
  Call('measurements_state');
  AssertEquals('the set open stays', 'Sam', Answer.Objects['set'].Strings['name']);
end;

procedure TTestEditorServer.TestMeasurementsMethodsTable;
var
  Tools: TJSONArray;
  Index: integer;
  Method: TApiMethod;
  ToolName: string;
begin
  Tools := McpTools;
  try
    for Index := 0 to Tools.Count - 1 do
    begin
      ToolName := Tools.Objects[Index].Strings['name'];
      AssertFalse(ToolName, ToolName.StartsWith(MEASUREMENTS_PREFIX));
    end;
  finally
    FreeAndNil(Tools);
  end;
  AssertTrue('its own table', Length(MeasurementsMethods) > 0);
  for Method in MeasurementsMethods do
    AssertTrue(Method.Name, Method.Name.StartsWith(MEASUREMENTS_PREFIX));
end;

procedure TTestEditorServer.TestLabelKeys;
var
  IdA, IdB, Flap: integer;
  Keys: string;
begin
  AddSquare;
  IdA := IdOf('A');
  IdB := IdOf('B');
  Flap := IdOf('Flap');
  Call('editor_label_keys', '{"mode": "none", "selection": [' + IntToStr(IdA) + ']}');
  AssertEquals('none', 0, Answer.Arrays['objects'].Count);
  Call('editor_label_keys', '{"selection": [' + IntToStr(IdA) + ']}');
  Keys := Answer.Arrays['objects'].AsJSON;
  AssertTrue('the selection', Pos(IntToStr(IdA), Keys) > 0);
  AssertTrue('not what is unrelated', Pos('[' + IntToStr(IdB) + ',', Keys + ',') = 0);
  Call('editor_label_keys', '{"mode": "all"}');
  AssertEquals('every point, edge and piece', 9, Answer.Arrays['objects'].Count);
  Call('editor_label_keys', '{"hover": "Flap"}');
  AssertEquals('the hovered piece', '[' + IntToStr(Flap) + ']', Answer.Arrays['objects'].AsJSON);
  Call('editor_label_keys', '{"suggestions": [' + IntToStr(IdB) + ']}');
  AssertEquals('what the suggestions read', '[' + IntToStr(IdB) + ']', Answer.Arrays['objects'].AsJSON);
  Call('editor_label_keys', '{"mode": "none", "suggestions": [' + IntToStr(IdB) + ']}');
  AssertEquals('none means none', 0, Answer.Arrays['objects'].Count);
  Call('editor_label_keys', '{"selection": [999]}');
  AssertEquals('an unknown ID is left out', 0, Answer.Arrays['objects'].Count);
end;

procedure TTestEditorServer.TestDependencyArrows;
var
  Arrow: TJSONObject;
begin
  AddSquare;
  Call('add_point', '{"type":"offsetPoint","name":"Offset","base":"A","mode":"cartesian","dx":"20","dy":"10"}');
  AssertEquals('offset added', 'Offset', Answer.Strings['name']);
  Call('editor_label_keys', '{"mode":"none","selection":["Offset"],"links":true}');
  AssertEquals('input arrow despite labels being hidden', 1, Answer.Arrays['links'].Count);
  Arrow := Answer.Arrays['links'].Objects[0];
  AssertFalse(Arrow.Booleans['dependent']);
  AssertEquals(20.0, Arrow.Floats['fromX'], 0.001);
  Call('editor_label_keys', '{"selection":["A"],"links":true,"dependents":true}');
  AssertEquals('only the offset, not the lines ending at A', 1, Answer.Arrays['links'].Count);
  AssertTrue(Answer.Arrays['links'].Objects[0].Booleans['dependent']);
end;

procedure TTestEditorServer.TestDeleteSelection;
begin
  AddSquare;
  Call('editor_delete', '{"selection": ["A"]}');
  AssertFalse('a point the edges use stays', Answer.Booleans['done']);
  AssertTrue('with the reason', Answer.Strings['message'] <> '');
  AssertTrue('the selection stays', Answer.Nulls['select']);
  Call('editor_delete', '{"selection": [' + IntToStr(IdOf('Flap')) + ']}');
  AssertTrue('the piece goes', Answer.Booleans['done']);
  AssertEquals('nothing is selected', 0, Answer.Arrays['select'].Count);
  Call('editor_scene');
  AssertEquals('no pieces', 0, Answer.Arrays['pieces'].Count);
  Call('undo');
  Call('editor_scene');
  AssertEquals('one undo step', 1, Answer.Arrays['pieces'].Count);
  Call('editor_delete', '{"selection": []}');
  AssertFalse('nothing selected, nothing done', Answer.Booleans['done']);
end;

// The first selected point, placed from the rest in order
procedure TTestEditorServer.TestConvertPoint;
begin
  AddSquare;
  Call('add_point', '{"type": "freePoint", "name": "M", "x": 50, "y": 2}');
  Call('editor_convert_point', '{"selection": [' + IntToStr(IdOf('M')) + ', ' + IntToStr(IdOf('Line_A_B')) +
    '], "type": "alongEdgePoint"}');
  AssertTrue(Answer.Strings['message'], Answer.Booleans['done']);
  AssertEquals('the point stays selected', '[' + IntToStr(IdOf('M')) + ']', Answer.Arrays['select'].AsJSON);
  Call('get_object', '{"name": "M"}');
  AssertEquals('alongEdgePoint', Answer.Strings['type']);
  Call('editor_convert_point', '{"selection": [' + IntToStr(IdOf('Line_A_B')) + '], "type": "freePoint"}');
  AssertFalse('an edge first', Answer.Booleans['done']);
  Call('editor_convert_point', '{"selection": [' + IntToStr(IdOf('M')) + '], "type": "spiral"}');
  AssertEquals('no such type', RPC_INVALID_PARAMS, ErrorCode);
  Call('editor_tables');
  AssertEquals('every type in the box', 8, Answer.Arrays['pointTypes'].Count);
end;

// The Garment tab: the pieces as sewn, as SVG with their outlines, and the
// marks of a selection
procedure TTestEditorServer.TestGarment;
var
  Pieces, Lines: TJSONArray;
  Bounds: TJSONObject;
  Flap: integer;
begin
  AddSquare;
  Flap := IdOf('Flap');
  Call('editor_garment');
  AssertEquals('drawn', 1, Pos('<svg', Answer.Strings['svg']));
  Pieces := Answer.Arrays['pieces'];
  AssertEquals('one piece', 1, Pieces.Count);
  AssertEquals(Flap, Pieces.Objects[0].Integers['id']);
  AssertEquals('Flap', Pieces.Objects[0].Strings['name']);
  AssertTrue('its outline, as x and y', Pieces.Objects[0].Arrays['outline'].Count >= 8);
  Bounds := Answer.Objects['bounds'];
  AssertEquals('as wide as drafted', 100, Bounds.Floats['right'] - Bounds.Floats['left'], 0.01);
  AssertEquals('every material shown', '', Answer.Strings['material']);
  AssertEquals('nothing left out', 0, Answer.Arrays['notes'].Count);

  Call('add_material', '{"name": "Lining"}');
  Call('editor_garment', '{"material": "Lining"}');
  AssertEquals('the material shown', 'Lining', Answer.Strings['material']);
  AssertEquals('none of it', 0, Answer.Arrays['pieces'].Count);
  AssertTrue('no box round nothing', Answer.Nulls['bounds']);
  AssertTrue('listed to choose', Pos('"Lining"', Answer.Arrays['materials'].AsJSON) > 0);
  Call('editor_garment', '{"material": "Velvet"}');
  AssertEquals('not a material: all of them', '', Answer.Strings['material']);
  AssertEquals(1, Answer.Arrays['pieces'].Count);

  Call('editor_garment_marks', '{"selection": [' + IntToStr(Flap) + ']}');
  AssertEquals('the piece outlined', '[' + IntToStr(Flap) + ']', Answer.Arrays['pieces'].AsJSON);
  AssertEquals('no seam', 0, Answer.Arrays['lines'].Count);
  Call('editor_garment_marks', '{"selection": [' + IntToStr(Flap) + '], "material": "Lining"}');
  AssertEquals('not shown, not outlined', 0, Answer.Arrays['pieces'].Count);
  Call('add_seam', '{"sideA": [{"piece": "Flap", "edge": "Line_A_B"}], "sideB": [{"piece": "Flap", "edge": "Line_C_D"}], ' +
    '"name": "Sewn"}');
  Call('editor_garment_marks', '{"selection": [' + IntToStr(IdOf('Sewn')) + ']}');
  Lines := Answer.Arrays['lines'];
  AssertEquals('both sides of the seam', 2, Lines.Count);
  AssertEquals('no piece selected', 0, Answer.Arrays['pieces'].Count);
end;

// The Problems tab's list: each problem with what it is about
procedure TTestEditorServer.TestProblems;
const
  WITH_HIP = '{"format": "measurements", "version": 1, "units": "mm", "measurements": [' +
    '{"key": "waist", "value": 720}, {"key": "hip", "value": 940}]}';
  // Another set without the hip, so what reads it fails
  NO_HIP = '{"format": "measurements", "version": 1, "units": "mm", "measurements": [' +
    '{"key": "waist", "value": 720}]}';
var
  Problems: TJSONArray;
  Kinds: string;
  Index: integer;
begin
  Call('editor_problems');
  AssertEquals('none yet', 0, Answer.Arrays['problems'].Count);
  AddSquare;
  Call('use_measurements', '{"text": "' + StringToJSONString(WITH_HIP) + '", "file": "me.slm"}');
  Call('add_point', '{"type": "freePoint", "name": "P", "x": "@hip / 4", "y": 0}');
  Call('use_measurements', '{"text": "' + StringToJSONString(NO_HIP) + '", "file": "other.slm"}');
  Call('add_variable', '{"name": "ease", "formula": "1 / 0"}');
  Call('add_edge', '{"type": "line", "start": "A", "end": "C", "role": "outline"}');
  Call('editor_problems');
  Problems := Answer.Arrays['problems'];
  Kinds := '';
  for Index := 0 to Problems.Count - 1 do
    Kinds := Kinds + Problems.Objects[Index].Strings['kind'] + ' ';
  AssertEquals('one of each', 'measurement variable object ', Kinds);
  AssertEquals('the measurement by key', 'hip', Problems.Objects[0].Strings['key']);
  AssertTrue('said in words', Pos('Line_A_C', Problems.Objects[2].Strings['text']) > 0);
  AssertEquals('the point reading the hip, counted', 1, Answer.Integers['blocked']);
  AssertEquals('the variable by ID', IdOf('ease'), Problems.Objects[1].Integers['id']);
  AssertEquals('the edge by ID', IdOf('Line_A_C'), Problems.Objects[2].Integers['id']);
end;

procedure TTestEditorServer.TestCopyAndPaste;
var
  Fragment: string;
  Pasted: TJSONArray;
  Params: TJSONObject;
begin
  AddSquare;
  Call('editor_copy', '{"selection": []}');
  AssertFalse('nothing selected', Answer.Booleans['done']);
  AssertTrue('says what to select', Answer.Strings['message'] <> '');
  AssertEquals('no text', '', Answer.Strings['text']);

  Call('editor_copy', '{"selection": ["A", "B", ' + IntToStr(IdOf('Line_A_B')) + ']}');
  AssertTrue('copied', Answer.Booleans['done']);
  Fragment := Answer.Strings['text'];
  AssertTrue('the fragment', Fragment <> '');
  AssertTrue('the names, for the plain text clipboard', Pos('A', Answer.Strings['names']) > 0);
  AssertTrue('copying changes nothing', Answer.Nulls['select']);

  Params := TJSONObject.Create(['text', Fragment]);
  try
    Call('editor_paste', Params.AsJSON);
  finally
    FreeAndNil(Params);
  end;
  AssertTrue('pasted', Answer.Booleans['done']);
  Pasted := Answer.Arrays['select'];
  AssertEquals('the copies are selected', 3, Pasted.Count);
  AssertTrue('the copies are new', Pasted.Integers[0] > IdOf('Flap'));
  Call('editor_scene');
  AssertEquals('two more points', 6, Answer.Arrays['points'].Count);
  Call('undo');
  Call('editor_scene');
  AssertEquals('one undo step', 4, Answer.Arrays['points'].Count);

  Call('editor_paste', '{"text": "not a fragment"}');
  AssertFalse('refused', Answer.Booleans['done']);
  AssertTrue('with the reason', Answer.Strings['message'] <> '');

  Call('editor_cut', '{"selection": [' + IntToStr(IdOf('Flap')) + ']}');
  AssertFalse('a piece cannot be copied, so it is not cut', Answer.Booleans['done']);
  Call('add_point', '{"type": "freePoint", "name": "E", "x": 200, "y": 0}');
  Call('editor_cut', '{"selection": ["E"]}');
  AssertTrue('cut', Answer.Booleans['done']);
  AssertTrue('with its fragment', Answer.Strings['text'] <> '');
  AssertEquals('nothing selected after', 0, Answer.Arrays['select'].Count);
  Call('editor_scene');
  AssertEquals('E is gone', 4, Answer.Arrays['points'].Count);
end;

procedure TTestEditorServer.TestImportVariables;
var
  Other: TPattern;
  Params: TJSONObject;
  Added: integer;
begin
  Call('add_variable', '{"name": "ease", "formula": "10"}');
  Other := TPattern.Create;
  Params := nil;
  try
    Other.AddVariable('ease', '25');
    Other.AddVariable('seam', '15');
    Params := TJSONObject.Create(['text', SavePatternToText(Other), 'fileName', 'other.sloper']);
    Call('editor_variable_import', Params.AsJSON);
  finally
    FreeAndNil(Params);
    FreeAndNil(Other);
  end;
  AssertTrue('imported', Answer.Booleans['done']);
  AssertTrue('ease kept, so a warning', Answer.Booleans['warning']);
  AssertTrue('says so', Pos('other.sloper', Answer.Strings['message']) > 0);
  AssertEquals('seam added', 1, Answer.Arrays['added'].Count);
  Added := Answer.Arrays['added'].Integers[0];
  AssertEquals('seam', IdOf('seam'), Added);
  Call('editor_variable_import', '{"text": "{}", "fileName": "bad.sloper"}');
  AssertFalse('refused', Answer.Booleans['done']);
  AssertTrue('with the reason', Answer.Strings['message'] <> '');
end;

procedure TTestEditorServer.TestSeamTool;
var
  SideA, SideB: string;
begin
  AddSquare;
  Call('editor_seam_pick', '{"x": 50, "y": 0, "radius": 2, "sideA": [], "sideB": []}');
  AssertTrue('picked', Answer.Booleans['picked']);
  AssertEquals('on side A', 1, Answer.Arrays['sideA'].Count);
  AssertTrue('the progress', Pos('Side A', Answer.Strings['message']) > 0);
  AssertEquals('its line to draw', 1, Answer.Objects['lines'].Arrays['sideA'].Count);
  SideA := Answer.Arrays['sideA'].AsJSON;
  Call('editor_seam_pick', '{"sideA": ' + SideA + ', "sideB": [], "onB": true}');
  AssertTrue('Tab: side B', Pos('Side B', Answer.Strings['message']) > 0);
  Call('editor_seam_pick', '{"x": 50, "y": 100, "radius": 2, "sideA": ' + SideA + ', "sideB": [], "onB": true}');
  SideB := Answer.Arrays['sideB'].AsJSON;
  AssertEquals('on side B', 1, Answer.Arrays['sideB'].Count);
  Call('editor_seam_pick', '{"x": 50, "y": 100, "radius": 2, "sideA": ' + SideA + ', "sideB": ' + SideB + ', "onB": true}');
  AssertEquals('a second click takes it off', 0, Answer.Arrays['sideB'].Count);
  Call('editor_seam_pick', '{"x": 500, "y": 500, "radius": 2, "sideA": ' + SideA + ', "sideB": []}');
  AssertFalse('nothing there', Answer.Booleans['picked']);
  AssertEquals('the side kept', 1, Answer.Arrays['sideA'].Count);
  Call('editor_seam_make', '{"sideA": ' + SideA + ', "sideB": []}');
  AssertFalse('both sides needed', Answer.Booleans['done']);
  Call('editor_seam_make', '{"sideA": ' + SideA + ', "sideB": ' + SideB + '}');
  AssertTrue('made', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('one step', 'Add seam', Answer.Strings['undo']);
end;

procedure TTestEditorServer.TestImportStamp;
const
  STAMP_SVG = '<svg xmlns="http://www.w3.org/2000/svg" width="20mm" height="10mm" viewBox="0 0 20 10">' +
    '<path d="M0 0 H20 V10 H0 Z"/></svg>';
var
  Note: TJSONObject;
  Params: string;
begin
  AddSquare;
  Params := '{"svg": "' + StringToJSONString(STAMP_SVG) + '", "fileName": "Fold.svg", "selection": [' +
    IntToStr(IdOf('A')) + '], "x": 300, "y": 250}';
  Call('editor_import_stamp', Params);
  AssertTrue('imported', Answer.Booleans['done']);
  AssertEquals('selects the stamp', 1, Answer.Arrays['select'].Count);
  AssertEquals('the dimensions are in millimetres', 0, Answer.Arrays['warnings'].Count);
  Call('editor_scene');
  Note := Answer.Arrays['notes'].Objects[0];
  AssertEquals('hangs from the selected point', 'point', Note.Strings['anchor']);
  AssertEquals('drawn as paths', 1, Note.Arrays['stamp'].Count);
  AssertNear('left of the anchor', -10, Note.Arrays['box'].Floats[0], TOLERANCE);
  AssertNear('right of the anchor', 10, Note.Arrays['box'].Floats[2], TOLERANCE);
  Call('undo');
  Answer;
  Call('editor_scene');
  AssertEquals('one undo removes the stamp', 0, Answer.Arrays['notes'].Count);
  Call('editor_import_stamp', '{"svg": "not SVG", "fileName": "Bad.svg", "x": 0, "y": 0}');
  AssertEquals('a bad file is refused', RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestSeamInScene;
var
  Piece: TJSONObject;
begin
  AddSquare;
  Call('editor_seam_pick', '{"x": 50, "y": 0, "radius": 2, "sideA": [], "sideB": []}');
  Call('editor_seam_make', '{"sideA": ' + Answer.Arrays['sideA'].AsJSON + ', "sideB": [{"piece": "Flap", "edge": ' +
    IntToStr(IdOf('Line_C_D')) + '}]}');
  Call('editor_scene');
  AssertEquals('the seam', 1, Answer.Arrays['seams'].Count);
  AssertEquals('side A', 1, Answer.Arrays['seams'].Objects[0].Arrays['sideA'].Count);
  AssertEquals('a chevron on each side, x, y and angle', 3, Answer.Arrays['seams'].Objects[0].Arrays['chevronsB'].Count);
  Piece := Answer.Arrays['pieces'].Objects[0];
  AssertTrue('the piece''s label', Pos('Flap', Piece.Strings['caption']) > 0);
  AssertNear('its middle', 50, Piece.Arrays['middle'].Floats[0], 1);
  AssertEquals('a chevron per edge', 12, Piece.Arrays['chevrons'].Count);
end;

procedure TTestEditorServer.TestNotesInScene;
var
  Note: TJSONObject;
begin
  Call('add_note', '{"text": "Cut 2\n{pattern.name}", "x": 10, "y": 20, "size": 12, "align": "centre"}');
  Answer;
  Call('editor_scene', '{"fileName": "skirt.sloper"}');
  AssertEquals('one note', 1, Answer.Arrays['notes'].Count);
  Note := Answer.Arrays['notes'].Objects[0];
  AssertEquals('two lines', 2, Note.Arrays['lines'].Count);
  AssertEquals('the field filled in', 'skirt', Note.Arrays['lines'].Strings[1]);
  AssertNear('size', 12, Note.Floats['size'], TOLERANCE);
  AssertTrue('a line is taller than its points', Note.Floats['lineHeight'] > 12 * 25.4 / 72);
  AssertEquals('align', 'centre', Note.Strings['align']);
  AssertNear('its text from its top left', 10, Note.Arrays['box'].Floats[0], TOLERANCE);
  AssertNear('down', 20, Note.Arrays['box'].Floats[1], TOLERANCE);
  AssertEquals('a free note has no leader', 0, Note.Arrays['leaderStrokes'].Count);
  Call('editor_scene');
  AssertEquals('no file, the field as typed', '{pattern.name}', Answer.Arrays['notes'].Objects[0].Arrays['lines'].Strings[1]);
end;

procedure TTestEditorServer.TestNoteHitFirst;
var
  Note: integer;
begin
  AddSquare;
  Call('add_note', '{"text": "Over the line", "x": 40, "y": -1}');
  Note := Answer.Integers['id'];
  Call('editor_objects_at', '{"x": 42, "y": 0, "pointRadius": 2, "edgeRadius": 2}');
  AssertEquals('the note first', Note, Answer.Arrays['objects'].Integers[0]);
  AssertTrue('then the edge under it', Answer.Arrays['objects'].Count > 1);
end;

procedure TTestEditorServer.TestTextTool;
var
  Note: integer;
begin
  AddSquare;
  Call('editor_tool_snap', '{"tool": "text", "x": 100.5, "y": 0.5, "radius": 2}');
  AssertTrue('hung from the point', Pos('B', Answer.Strings['description']) > 0);
  Call('editor_tool_click', '{"tool": "text", "x": 100.5, "y": 0.5, "radius": 2}');
  AssertTrue('made', Answer.Booleans['done']);
  Note := Selected;
  Call('get_object', '{"id": ' + IntToStr(Note) + '}');
  AssertEquals('a note', 'note', Answer.Strings['type']);
  AssertEquals('saying Text', 'Text', Answer.Strings['text']);
  Call('editor_changes');
  AssertEquals('its step', 'Add note', Answer.Strings['undo']);
end;

procedure TTestEditorServer.TestCalloutTool;
var
  Note: TJSONObject;
begin
  AddSquare;
  Call('editor_tool_click', '{"tool": "callout", "x": 300, "y": 300, "radius": 2}');
  AssertFalse('nothing to point at', Answer.Booleans['started']);
  AssertTrue('says so', Answer.Strings['message'] <> '');
  Call('editor_tool_click', '{"tool": "callout", "x": 100.5, "y": 0.5, "radius": 2}');
  AssertTrue('the tip on B', Answer.Booleans['started']);
  Call('editor_tool_snap', '{"tool": "callout", "x": 150, "y": -40, "radius": 2, "start": {"x": 100.5, "y": 0.5, ' +
    '"radius": 2}}');
  AssertTrue('asks where the text goes', Pos('text goes', Answer.Strings['description']) > 0);
  Call('editor_tool_click', '{"tool": "callout", "x": 150, "y": -40, "radius": 2, "start": {"x": 100.5, "y": 0.5, ' +
    '"radius": 2}}');
  AssertTrue('made', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Add callout', Answer.Strings['undo']);
  Call('editor_scene');
  Note := Answer.Arrays['notes'].Objects[0];
  AssertEquals('an arrow', 'arrow', Note.Strings['leader']);
  AssertTrue('its leader drawn', Note.Arrays['leaderStrokes'].Count >= 4);
  AssertNear('pointing at B', 100, Note.Arrays['anchorAt'].Floats[0], TOLERANCE);
  AssertNear('its text where clicked', 150, Note.Arrays['box'].Floats[0], 0.1);
end;

procedure TTestEditorServer.TestMissingParamRefused;
begin
  Call('editor_snap', '{"x": 1, "radius": 2}');
  AssertEquals('no y', RPC_INVALID_PARAMS, ErrorCode);
  Call('editor_objects_in_box', '{"minX": 0, "minY": 0, "maxX": 1}');
  AssertEquals('no maxY', RPC_INVALID_PARAMS, ErrorCode);
end;

procedure TTestEditorServer.TestNotOfferedAsTools;
var
  Tools: TJSONArray;
  Index: integer;
  ToolName: string;
begin
  Tools := McpTools;
  try
    for Index := 0 to Tools.Count - 1 do
    begin
      ToolName := Tools.Objects[Index].Strings['name'];
      AssertFalse(ToolName, ToolName.StartsWith('editor_'));
    end;
  finally
    FreeAndNil(Tools);
  end;
  AssertTrue('the editor has its own table', Length(EditorMethods) > 0);
end;

procedure TTestEditorServer.TestApiMethodsStillServed;
begin
  AddSquare;
  Call('list_objects');
  Answer;
  Call('no_such_method');
  AssertEquals('unknown', RPC_METHOD_NOT_FOUND, ErrorCode);
end;

procedure TTestEditorServer.TestComplete;
var
  Items: TJSONArray;
begin
  Call('add_variable', '{"name": "width", "formula": "100"}');
  Call('editor_complete', '{"text": "wi", "caret": 2}');
  AssertEquals('from', 0, Answer.Integers['from']);
  AssertEquals('upto', 2, Answer.Integers['upto']);
  Items := Answer.Arrays['items'];
  AssertTrue('offered', Items.Count > 0);
  AssertEquals('the variable', 'width', Items.Objects[0].Strings['name']);
  Call('editor_complete', '{"text": "", "caret": 0}');
  AssertEquals('nothing unasked', 0, Answer.Arrays['items'].Count);
  Call('editor_complete', '{"text": "", "caret": 0, "explicit": true}');
  AssertTrue('everything when asked', Answer.Arrays['items'].Count > 0);
end;

procedure TTestEditorServer.TestCompleteCountsCharacters;
begin
  Call('add_variable', '{"name": "width", "formula": "100"}');
  Call('editor_complete', '{"text": "2×wi", "caret": 4}');
  AssertEquals('from, after the ×', 2, Answer.Integers['from']);
  AssertEquals('upto', 4, Answer.Integers['upto']);
  AssertEquals('the variable', 'width', Answer.Arrays['items'].Objects[0].Strings['name']);
end;

procedure TTestEditorServer.TestCompleteForObject;
var
  Items: TJSONArray;
  Index: integer;
begin
  AddSquare;
  Call('editor_complete', '{"name": "A", "text": "A", "caret": 1}');
  Items := Answer.Arrays['items'];
  for Index := 0 to Items.Count - 1 do
    AssertFalse('a formula cannot read its own object', Items.Objects[Index].Strings['name'] = 'A');
  Call('editor_complete', '{"name": "Nothing", "text": "A", "caret": 1}');
  AssertEquals('unknown target', RPC_REFUSED, ErrorCode);
  Call('editor_complete', '{"text": "A", "caret": 1.5}');
  AssertEquals('caret a whole number', RPC_INVALID_PARAMS, ErrorCode);
end;

procedure TTestEditorServer.TestListObjects;
var
  Rows: TJSONArray;
begin
  AddSquare;
  Call('editor_list_objects');
  Rows := Answer.Arrays['rows'];
  AssertEquals('every object', 9, Rows.Count);
  AssertEquals('first', 'A', Rows.Objects[0].Strings['name']);
  AssertEquals('state', 'valid', Rows.Objects[0].Strings['state']);
  AssertTrue('operation', Rows.Objects[0].Strings['operation'] <> '');
  Call('editor_list_objects', '{"filter": "points"}');
  AssertEquals('points', 4, Answer.Arrays['rows'].Count);
  Call('editor_list_objects', '{"filter": "pieces", "search": "fla"}');
  AssertEquals('found by name', 1, Answer.Arrays['rows'].Count);
  Call('editor_list_objects', '{"filter": "curves"}');
  AssertEquals('unknown filter', RPC_INVALID_PARAMS, ErrorCode);
end;

procedure TTestEditorServer.TestListVariables;
var
  Rows: TJSONArray;
begin
  Call('add_variable', '{"name": "ease", "formula": "5 * 2", "description": "Some ease"}');
  Call('add_variable', '{"name": "width", "formula": "100"}');
  Call('editor_list_variables', '{"search": "some"}');
  Rows := Answer.Arrays['rows'];
  AssertEquals('found by description', 1, Rows.Count);
  AssertEquals('name', 'ease', Rows.Objects[0].Strings['name']);
  AssertEquals('formula', '5 * 2', Rows.Objects[0].Strings['formula']);
  AssertTrue('value', Pos('10', Rows.Objects[0].Strings['value']) > 0);
end;

procedure TTestEditorServer.TestListMeasurements;
var
  Path: string;
  Rows: TJSONArray;
begin
  Path := ConcatPaths([ExtractFileDir(ExpandFileName(ParamStr(0))), 'patterns', 'skirt-pieces.sloper']);
  Call('open', '{"path": "' + StringToJSONString(Path) + '"}');
  Answer;
  Call('editor_list_measurements', '{"search": "waist"}');
  Rows := Answer.Arrays['rows'];
  AssertTrue('found', Rows.Count > 0);
  AssertTrue('by key or description', Pos('waist', LowerCase(Rows.Objects[0].Strings['key'] + Rows.Objects[0].Strings['description'])) > 0);
  AssertFalse('in the file', Rows.Objects[0].Booleans['missing']);
  AssertTrue('with its value', Rows.Objects[0].Strings['value'] <> '');
end;

procedure TTestEditorServer.TestSuggest;
var
  Items: TJSONArray;
  Index: integer;
  Found, FoundPoint: boolean;
  IdC: integer;
begin
  Call('add_variable', '{"name": "width", "formula": "100"}');
  AddSquare;
  IdC := IdOf('C');
  FoundPoint := False;
  Call('editor_suggest', '{"name": "B", "field": "x", "value": 100.3}');
  AssertEquals('kind', 'length', Answer.Strings['kind']);
  AssertTrue('tolerance', Answer.Strings['tolerance'] <> '');
  Items := Answer.Arrays['items'];
  Found := False;
  for Index := 0 to Items.Count - 1 do
    if Items.Objects[Index].Strings['text'] = '#width' then
    begin
      Found := True;
      AssertNear('value', 100, Items.Objects[Index].Floats['value'], TOLERANCE);
      AssertNear('delta', -0.3, Items.Objects[Index].Floats['delta'], TOLERANCE);
      AssertEquals('a variable is not on the canvas', 0, Items.Objects[Index].Arrays['objects'].Count);
    end
    else if Items.Objects[Index].Strings['text'] = 'C.x' then
    begin
      FoundPoint := True;
      AssertEquals('the object it reads', '[' + IntToStr(IdC) + ']', Items.Objects[Index].Arrays['objects'].AsJSON);
    end;
  AssertTrue('the variable is suggested', Found);
  AssertTrue('a point is suggested', FoundPoint);
  AssertFalse('nearest', Answer.Nulls['nearest']);
end;

procedure TTestEditorServer.TestSuggestRefused;
begin
  AddSquare;
  Call('editor_suggest', '{"name": "B", "field": "colour"}');
  AssertEquals('no such field', RPC_REFUSED, ErrorCode);
  Call('editor_suggest', '{"name": "B"}');
  AssertEquals('no field', RPC_INVALID_PARAMS, ErrorCode);
end;

procedure TTestEditorServer.TestTables;
var
  Tools, Commands, Shortcuts: TJSONArray;
  Index: integer;
  Found: boolean;
begin
  Call('editor_tables');
  Tools := Answer.Arrays['tools'];
  AssertEquals('every tool', 12, Tools.Count);
  AssertEquals('first', 'select', Tools.Objects[0].Strings['name']);
  AssertEquals('point tool', 'point', Tools.Objects[2].Strings['name']);
  AssertEquals('its caption', 'Point', Tools.Objects[2].Strings['caption']);
  AssertTrue('its hint', Tools.Objects[2].Strings['hint'] <> '');
  AssertEquals('its icon', 'point', Tools.Objects[2].Strings['icon']);
  AssertTrue('its keys', Tools.Objects[2].Strings['keys'] <> '');
  Commands := Answer.Arrays['commands'];
  AssertTrue('commands', Commands.Count > 0);
  AssertTrue('a command has a place', Commands.Objects[0].Strings['place'] <> '');
  Shortcuts := Answer.Arrays['shortcuts'];
  Found := False;
  for Index := 0 to Shortcuts.Count - 1 do
    if Shortcuts.Objects[Index].Strings['command'] = 'undo' then
    begin
      Found := True;
      AssertEquals('undo is a command', 'command', Shortcuts.Objects[Index].Strings['kind']);
      AssertEquals('in the edit group', 'edit', Shortcuts.Objects[Index].Strings['group']);
      AssertEquals('its keys', 'Mod+Z', Shortcuts.Objects[Index].Strings['keys']);
    end;
  AssertTrue('undo listed', Found);
  AssertEquals('roles', 'outline', Answer.Arrays['roles'].Objects[1].Strings['name']);
  AssertEquals('outline in ink', '', Answer.Arrays['roles'].Objects[1].Strings['color']);
  AssertEquals('solid', 0, Answer.Arrays['roles'].Objects[1].Arrays['dashes'].Count);
  AssertEquals('stitch', 'stitch', Answer.Arrays['roles'].Objects[3].Strings['name']);
  AssertEquals('dashed', '[1, 1]', Answer.Arrays['roles'].Objects[3].Arrays['dashes'].AsJSON);
end;

// The changes editor_changes names, joined by spaces
function ChangeNames(Answer: TJSONObject): string;
var
  Index: integer;
begin
  Result := '';
  for Index := 0 to Answer.Arrays['changes'].Count - 1 do
    Result := Trim(Result + ' ' + Answer.Arrays['changes'].Strings[Index]);
end;

procedure TTestEditorServer.TestChanges;
begin
  Call('editor_changes');
  AssertEquals('nothing yet', '', ChangeNames(Answer));
  AssertFalse('nothing to undo', Answer.Booleans['canUndo']);
  Call('add_point', '{"type": "freePoint", "name": "A", "x": 0, "y": 0}');
  Call('editor_changes');
  AssertEquals('an edit', 'pattern history file', ChangeNames(Answer));
  AssertTrue('can undo', Answer.Booleans['canUndo']);
  AssertTrue('its name', Answer.Strings['undo'] <> '');
  AssertFalse('nothing to redo', Answer.Booleans['canRedo']);
  AssertTrue('modified', Answer.Booleans['modified']);
  Call('editor_changes');
  AssertEquals('told once', '', ChangeNames(Answer));
  Call('editor_scene');
  Call('editor_snap', '{"x": 1, "y": 1, "radius": 2}');
  Call('editor_changes');
  AssertEquals('reading changes nothing', '', ChangeNames(Answer));
  Call('add_point', '{"type": "freePoint", "name": "B", "x": 10, "y": 0}');
  Call('add_point', '{"type": "freePoint", "name": "C", "x": 20, "y": 0}');
  Call('editor_changes');
  AssertEquals('gathered', 'pattern history', ChangeNames(Answer));
end;

procedure TTestEditorServer.TestChangesAfterUndo;
begin
  Call('add_point', '{"type": "freePoint", "name": "A", "x": 0, "y": 0}');
  Call('editor_changes');
  Call('undo');
  Call('editor_changes');
  AssertTrue('new objects', Pos('objectsReplaced', ChangeNames(Answer)) > 0);
  AssertTrue('history', Pos('history', ChangeNames(Answer)) > 0);
  AssertTrue('can redo', Answer.Booleans['canRedo']);
  AssertFalse('not modified', Answer.Booleans['modified']);
end;

procedure TTestEditorServer.TestChangesOnOpen;
var
  Generation: integer;
begin
  Call('editor_changes');
  Generation := Answer.Integers['generation'];
  Call('add_point', '{"type": "freePoint", "name": "A", "x": 0, "y": 0}');
  Call('save', '{"text": true}');
  Call('open', '{"text": "' + StringToJSONString(Answer.Strings['text']) + '"}');
  Call('editor_changes');
  AssertEquals('another pattern', Generation + 1, Answer.Integers['generation']);
  AssertEquals('everything', 'pattern objectsReplaced measurements history file', ChangeNames(Answer));
  AssertFalse('no history', Answer.Booleans['canUndo']);
end;

procedure TTestEditorServer.TestDragPoint;
begin
  AddSquare;
  Call('editor_changes');
  Call('editor_drag_begin', '{"name": "C"}');
  AssertNear('starts where it is', 100, Answer.Floats['x'], TOLERANCE);
  Call('editor_drag_to', '{"x": 120, "y": 110}');
  AssertTrue('moved', Answer.Booleans['moved']);
  AssertNear('there', 120, Answer.Floats['x'], TOLERANCE);
  Call('editor_drag_to', '{"x": 130, "y": 140}');
  Call('editor_changes');
  AssertEquals('worked out while dragging', 'pattern', ChangeNames(Answer));
  Call('editor_scene');
  AssertNear('the scene follows', 140, Answer.Arrays['points'].Objects[2].Floats['y'], TOLERANCE);
  Call('editor_drag_end');
  AssertTrue('changed', Answer.Booleans['changed']);
  Call('editor_changes');
  AssertEquals('one step', 'Move point', Answer.Strings['undo']);
  Call('undo');
  Call('get_object', '{"name": "C"}');
  AssertNear('undone at once', 100, Answer.Floats['x'], TOLERANCE);
  Call('editor_changes');
  AssertTrue('the piece next', Answer.Strings['undo'] <> 'Move point');
end;

procedure TTestEditorServer.TestDragCancel;
begin
  AddSquare;
  Call('editor_drag_begin', '{"name": "C"}');
  Call('editor_drag_to', '{"x": 150, "y": 150}');
  Call('editor_drag_cancel');
  AssertFalse('nothing', Answer.Booleans['changed']);
  Call('get_object', '{"name": "C"}');
  AssertNear('back', 100, Answer.Floats['x'], TOLERANCE);
  Call('editor_drag_begin', '{"name": "C"}');
  Call('editor_drag_end');
  AssertFalse('ended where it began', Answer.Booleans['changed']);
end;

procedure TTestEditorServer.TestDragOneField;
begin
  AddSquare;
  Call('editor_drag_begin', '{"name": "C", "field": "x"}');
  AssertEquals('a line to keep to', 'line', Answer.Objects['guide'].Strings['kind']);
  AssertNear('level with it', 100, Answer.Objects['guide'].Floats['y1'], TOLERANCE);
  Call('editor_drag_to', '{"x": 130, "y": 160}');
  AssertNear('across', 130, Answer.Floats['x'], TOLERANCE);
  AssertNear('not down', 100, Answer.Floats['y'], TOLERANCE);
  Call('editor_drag_end');
  Call('editor_drag_begin', '{"name": "C", "field": "colour"}');
  AssertEquals('no such field', RPC_REFUSED, ErrorCode);
end;

// A point whose x is a formula moves only up and down, along a guide
procedure TTestEditorServer.TestDragPartlyFormula;
begin
  AddSquare;
  Call('set_formula', '{"name": "C", "field": "x", "formula": "B.x"}');
  Call('editor_drag_begin', '{"name": "C"}');
  AssertEquals('a line to keep to', 'line', Answer.Objects['guide'].Strings['kind']);
  AssertNear('upright through it', 100, Answer.Objects['guide'].Floats['x2'], TOLERANCE);
  Call('editor_drag_to', '{"x": 130, "y": 160}');
  AssertTrue('moved', Answer.Booleans['moved']);
  AssertNear('not across', 100, Answer.Floats['x'], TOLERANCE);
  AssertNear('down', 160, Answer.Floats['y'], TOLERANCE);
  Call('editor_drag_end');
  Call('get_object', '{"name": "C"}');
  AssertEquals('x keeps its formula', 'B.x', Answer.Objects['formulas'].Strings['x']);
end;

procedure TTestEditorServer.TestDragNote;
begin
  Call('add_note', '{"text": "Cut 2", "x": 10, "y": 20}');
  Answer;
  Call('editor_drag_begin', '{"name": "' + Answer.Strings['name'] + '"}');
  AssertNear('top left', 10, Answer.Floats['x'], TOLERANCE);
  Call('editor_drag_to', '{"x": 40, "y": 50}');
  AssertNear('moved', 40, Answer.Floats['x'], TOLERANCE);
  Call('editor_drag_end');
  Call('editor_changes');
  AssertEquals('its step', 'Move note', Answer.Strings['undo']);
end;

procedure TTestEditorServer.TestDragBlocksChanges;
begin
  AddSquare;
  Call('editor_drag_begin', '{"name": "C"}');
  Call('add_point', '{"type": "freePoint", "name": "E", "x": 5, "y": 5}');
  AssertEquals('an API change', RPC_REFUSED, ErrorCode);
  Call('editor_tool_click', '{"tool": "point", "x": 300, "y": 300, "radius": 2}');
  AssertEquals('an editor change', RPC_REFUSED, ErrorCode);
  Call('undo');
  AssertEquals('undo', RPC_REFUSED, ErrorCode);
  Call('editor_drag_begin', '{"name": "B"}');
  AssertEquals('a second drag', RPC_REFUSED, ErrorCode);
  Call('editor_scene');
  Answer;
  Call('editor_drag_end');
  Call('add_point', '{"type": "freePoint", "name": "E", "x": 5, "y": 5}');
  Answer;
end;

procedure TTestEditorServer.TestDragRefusals;
begin
  AddSquare;
  Call('editor_drag_to', '{"x": 1, "y": 1}');
  AssertEquals('no drag', RPC_REFUSED, ErrorCode);
  Call('editor_drag_end');
  AssertEquals('none to end', RPC_REFUSED, ErrorCode);
  Call('editor_drag_begin', '{"name": "Flap"}');
  AssertEquals('a piece', RPC_REFUSED, ErrorCode);
  Call('set_locked', '{"name": "C", "locked": true}');
  Call('editor_drag_begin', '{"name": "C"}');
  AssertEquals('locked', RPC_REFUSED, ErrorCode);
  // No change was left open
  Call('add_point', '{"type": "freePoint", "name": "E", "x": 5, "y": 5}');
  Answer;
end;

procedure TTestEditorServer.TestHandles;
var
  Handles: TJSONArray;
  Curve: integer;
begin
  AddSquare;
  Call('add_edge', '{"type": "curve", "name": "Arch", "start": "A", "end": "B", "angle1": 270, "length1": 30, ' +
    '"angle2": 270, "length2": 30}');
  Curve := IdOf('Arch');
  Call('editor_handles', '{"selection": ["A"]}');
  AssertEquals('no curve selected', 0, Answer.Arrays['handles'].Count);
  Call('editor_handles', '{"selection": ["Arch"]}');
  Handles := Answer.Arrays['handles'];
  AssertEquals('two', 2, Handles.Count);
  AssertEquals('its curve', Curve, Handles.Objects[0].Integers['edge']);
  AssertEquals('named by its length', 'length1', Handles.Objects[0].Strings['field']);
  AssertNear('starts at the curve''s start', 0, Handles.Objects[0].Floats['anchorY'], TOLERANCE);
  AssertNear('ends below it', 30, Handles.Objects[0].Floats['y'], TOLERANCE);
  AssertTrue('draggable', Handles.Objects[0].Booleans['draggable']);
  Call('editor_objects_at', '{"x": 100, "y": 29, "pointRadius": 2, "edgeRadius": 2, "selection": ["Arch"]}');
  AssertEquals('the second handle', 'length2', Answer.Objects['handle'].Strings['field']);
  Call('editor_objects_at', '{"x": 100, "y": 29, "pointRadius": 2, "edgeRadius": 2, "selection": []}');
  AssertTrue('not while unselected', Answer.Nulls['handle']);
  Call('editor_objects_at', '{"x": 100, "y": 29, "pointRadius": 2, "edgeRadius": 2}');
  AssertNull('only asked with a selection', Answer.Find('handle'));
end;

procedure TTestEditorServer.TestDragHandle;
begin
  AddSquare;
  Call('add_edge', '{"type": "curve", "name": "Arch", "start": "A", "end": "B", "angle1": 270, "length1": 30, ' +
    '"angle2": 270, "length2": 30}');
  Call('editor_drag_begin', '{"name": "Arch", "handle": "length1"}');
  AssertNear('starts at the handle', 30, Answer.Floats['y'], TOLERANCE);
  Call('editor_drag_to', '{"x": 40, "y": 0}');
  AssertTrue('moved', Answer.Booleans['moved']);
  AssertNear('across', 40, Answer.Floats['x'], TOLERANCE);
  AssertNear('level', 0, Answer.Floats['y'], TOLERANCE);
  Call('editor_drag_end');
  Call('get_object', '{"name": "Arch"}');
  AssertEquals('angle', '0', Answer.Objects['formulas'].Strings['angle1']);
  AssertEquals('length', '40', Answer.Objects['formulas'].Strings['length1']);
  Call('editor_changes');
  AssertEquals('its step', 'Move curve handle', Answer.Strings['undo']);
  Call('editor_drag_begin', '{"name": "Arch", "handle": "angle1"}');
  AssertEquals('not a handle', RPC_REFUSED, ErrorCode);
  Call('editor_drag_begin', '{"name": "Line_A_B", "handle": "length1"}');
  AssertEquals('a line has none', RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestHandleFormulaRefused;
begin
  AddSquare;
  Call('add_edge', '{"type": "curve", "name": "Arch", "start": "A", "end": "B", "angle1": 270, "length1": "15 * 2", ' +
    '"angle2": 270, "length2": 30}');
  Call('editor_handles', '{"selection": ["Arch"]}');
  AssertFalse('set by a formula', Answer.Arrays['handles'].Objects[0].Booleans['draggable']);
  AssertTrue('the other is not', Answer.Arrays['handles'].Objects[1].Booleans['draggable']);
  Call('editor_drag_begin', '{"name": "Arch", "handle": "length1"}');
  AssertEquals('refused', RPC_REFUSED, ErrorCode);
  Call('add_point', '{"type": "freePoint", "name": "E", "x": 5, "y": 5}');
  Answer;
end;

function TTestEditorServer.AddCallout: integer;
begin
  Call('editor_tool_click', '{"tool": "callout", "x": 100, "y": 0, "radius": 2}');
  Call('editor_tool_click', '{"tool": "callout", "x": 150, "y": -40, "radius": 2, "start": {"x": 100, "y": 0, ' +
    '"radius": 2}}');
  Result := Answer.Arrays['select'].Integers[0];
end;

procedure TTestEditorServer.TestDragCalloutTip;
var
  Callout: integer;
  Note: TJSONObject;
begin
  AddSquare;
  Callout := AddCallout;
  Call('editor_objects_at', '{"x": 100.5, "y": 0.5, "pointRadius": 2, "edgeRadius": 2, "selection": [' +
    IntToStr(Callout) + ']}');
  AssertEquals('its tip', Callout, Answer.Integers['tip']);
  Call('editor_objects_at', '{"x": 100.5, "y": 0.5, "pointRadius": 2, "edgeRadius": 2, "selection": []}');
  AssertTrue('not while unselected', Answer.Nulls['tip']);
  Call('editor_changes');
  Call('editor_drag_begin', '{"id": ' + IntToStr(Callout) + ', "tip": true}');
  AssertNear('starts at B', 100, Answer.Floats['x'], TOLERANCE);
  Call('editor_drag_to', '{"x": 0.5, "y": 0.5, "radius": 2}');
  AssertEquals('snaps to A', 'point', Answer.Strings['kind']);
  AssertNear('there', 0, Answer.Floats['x'], TOLERANCE);
  AssertTrue('says what it points at', Pos('A', Answer.Strings['message']) > 0);
  AssertTrue('its leader to draw', Answer.Arrays['leaderStrokes'].Count >= 4);
  Call('editor_changes');
  AssertEquals('nothing changed yet', '', ChangeNames(Answer));
  Call('editor_drag_end');
  AssertTrue('changed', Answer.Booleans['changed']);
  Call('editor_changes');
  AssertEquals('its step', 'Move callout tip', Answer.Strings['undo']);
  Call('editor_scene');
  Note := Answer.Arrays['notes'].Objects[0];
  AssertNear('pointing at A', 0, Note.Arrays['anchorAt'].Floats[0], TOLERANCE);
  AssertNear('its text stays', 150, Note.Arrays['box'].Floats[0], 0.1);
  Call('editor_drag_begin', '{"id": ' + IntToStr(Callout) + ', "tip": true}');
  Call('editor_drag_to', '{"x": 100.5, "y": 99.5, "radius": 2}');
  Call('editor_drag_cancel');
  AssertFalse('cancelled', Answer.Booleans['changed']);
  Call('editor_drag_begin', '{"id": ' + IntToStr(Callout) + ', "tip": true}');
  Call('editor_drag_end');
  AssertFalse('never moved', Answer.Booleans['changed']);
end;

procedure TTestEditorServer.TestCalloutTipRefusals;
var
  Callout: integer;
begin
  AddSquare;
  Callout := AddCallout;
  Call('editor_drag_begin', '{"id": ' + IntToStr(Callout) + ', "tip": true}');
  Call('editor_drag_to', '{"x": 300, "y": 300, "radius": 2}');
  AssertEquals('free', 'free', Answer.Strings['kind']);
  Call('editor_drag_end');
  AssertEquals('a tip on nothing', RPC_REFUSED, ErrorCode);
  // The drop left no change open
  Call('add_point', '{"type": "freePoint", "name": "E", "x": 5, "y": 5}');
  Answer;
  Call('editor_drag_begin', '{"name": "A", "tip": true}');
  AssertEquals('a point has no tip', RPC_REFUSED, ErrorCode);
  Call('set_locked', '{"id": ' + IntToStr(Callout) + ', "locked": true}');
  Call('editor_drag_begin', '{"id": ' + IntToStr(Callout) + ', "tip": true}');
  AssertEquals('locked', RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestBounds;
var
  Bounds: TJSONArray;
begin
  AddSquare;
  Call('editor_bounds', '{"ids": ["A", "C"]}');
  Bounds := Answer.Arrays['bounds'];
  AssertNear('left', 0, Bounds.Floats[0], TOLERANCE);
  AssertNear('bottom', 100, Bounds.Floats[3], TOLERANCE);
  Call('editor_bounds', '{"ids": []}');
  AssertTrue('nothing', Answer.Nulls['bounds']);
end;

procedure TTestEditorServer.TestListClick;
const
  Visible = '"visible": ["1", "2", "3", "chest"]';
begin
  Call('editor_list_click', '{' + Visible + ', "selected": ["1"], "anchor": "1", "clicked": "3"}');
  AssertEquals('a click', '[3]', Answer.Arrays['selection'].AsJSON);
  Call('editor_list_click', '{' + Visible + ', "selected": ["1"], "anchor": "1", "clicked": "3", "toggle": true}');
  AssertEquals('added', '[1, 3]', Answer.Arrays['selection'].AsJSON);
  Call('editor_list_click', '{' + Visible + ', "selected": ["2"], "anchor": "2", "clicked": "chest", "extend": true}');
  AssertEquals('a range, keys as text', '[2, 3, "chest"]', Answer.Arrays['selection'].AsJSON);
  Call('editor_list_click', '{' + Visible + ', "selected": []}');
  AssertEquals('no row', RPC_INVALID_PARAMS, ErrorCode);
end;

procedure TTestEditorServer.TestVariableEdits;
var
  Variable: integer;
begin
  AddSquare;
  Call('editor_variable_add');
  Variable := Answer.Integers['id'];
  Call('editor_changes');
  AssertEquals('its step', 'Add variable', Answer.Strings['undo']);
  Call('editor_variable_set', '{"id": ' + IntToStr(Variable) + ', "column": "name", "text": " ease "}');
  AssertTrue('renamed', Answer.Booleans['done']);
  Call('editor_variable_set', '{"name": "ease", "column": "formula", "text": "12 +"}');
  AssertFalse('refused', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['reason'] <> '');
  Call('editor_variable_set', '{"name": "ease", "column": "formula", "text": "12 * 2"}');
  AssertTrue('a formula', Answer.Booleans['done']);
  Call('editor_variable_set', '{"name": "ease", "column": "description", "text": "Wearing ease"}');
  Call('editor_list_variables');
  AssertEquals('listed', 'ease', Answer.Arrays['rows'].Objects[0].Strings['name']);
  AssertEquals('its formula', '12 * 2', Answer.Arrays['rows'].Objects[0].Strings['formula']);
  AssertEquals('its description', 'Wearing ease', Answer.Arrays['rows'].Objects[0].Strings['description']);
  Call('editor_variable_set', '{"name": "ease", "column": "value", "text": "3"}');
  AssertEquals('the value is worked out', RPC_INVALID_PARAMS, ErrorCode);
  // Read by a point, it cannot go
  Call('add_point', '{"type": "freePoint", "name": "E", "x": "#ease", "y": 0}');
  Answer;
  Call('editor_variable_delete', '{"name": "ease"}');
  AssertEquals('read by E', RPC_REFUSED, ErrorCode);
  Call('delete', '{"name": "E"}');
  Call('editor_variable_delete', '{"name": "ease"}');
  AssertTrue('deleted', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Delete variable', Answer.Strings['undo']);
  Call('editor_variable_delete', '{"name": "A"}');
  AssertEquals('not a variable', RPC_REFUSED, ErrorCode);
end;

function TTestEditorServer.PropertyRow(const RowId: string): TJSONObject;
var
  Index: integer;
  Rows: TJSONArray;
begin
  Rows := Answer.Arrays['rows'];
  for Index := 0 to Rows.Count - 1 do
    if Rows.Objects[Index].Strings['id'] = RowId then
      Exit(Rows.Objects[Index]);
  Fail('No row ' + RowId + ' in ' + Rows.AsJSON);
  Result := nil;
end;

function TTestEditorServer.HasPropertyRow(const RowId: string): boolean;
var
  Index: integer;
  Rows: TJSONArray;
begin
  Rows := Answer.Arrays['rows'];
  for Index := 0 to Rows.Count - 1 do
    if Rows.Objects[Index].Strings['id'] = RowId then
      Exit(True);
  Result := False;
end;

procedure TTestEditorServer.TestProperties;
var
  Rows: TJSONArray;
  Ids: string;
  Index, IdA: integer;
begin
  AddSquare;
  IdA := IdOf('A');
  Call('editor_properties', '{"selection": [' + IntToStr(IdA) + ']}');
  AssertEquals('shown', IdA, Answer.Integers['id']);
  Rows := Answer.Arrays['rows'];
  Ids := '';
  for Index := 0 to Rows.Count - 1 do
    Ids := Ids + Rows.Objects[Index].Strings['id'] + ' ';
  AssertEquals('in order', 'type name locked x y marker markedOn result problem ', Ids);
  AssertEquals('its name', 'A', PropertyRow('name').Strings['text']);
  AssertEquals('edited', 'name', PropertyRow('name').Strings['kind']);
  AssertEquals('a formula', 'formula', PropertyRow('x').Strings['kind']);
  AssertEquals('its field', 'x', PropertyRow('x').Strings['field']);
  AssertEquals('its formula', '0', PropertyRow('x').Strings['text']);
  AssertEquals('plain', 0, PropertyRow('marker').Integers['choice']);
  AssertEquals('markers', 5, PropertyRow('marker').Arrays['choices'].Count);
  AssertFalse('unlocked', PropertyRow('locked').Booleans['checked']);
  AssertTrue('with a hint', PropertyRow('locked').Strings['hint'] <> '');
  AssertEquals('no problem', '', PropertyRow('problem').Strings['text']);
  Call('editor_properties', '{"selection": ["Line_A_B"]}');
  AssertEquals('its type can change', 'choice', PropertyRow('type').Strings['kind']);
  AssertEquals('a line', 0, PropertyRow('type').Integers['choice']);
  AssertEquals('outline', 1, PropertyRow('role').Integers['choice']);
  AssertEquals('its length', 'Length', PropertyRow('result').Strings['caption']);
  Call('editor_properties', '{"selection": ["A", "B"]}');
  AssertTrue('none shown', Answer.Nulls['id']);
  AssertEquals('how many', '2 objects selected', Answer.Strings['title']);
  AssertEquals('no rows', 0, Answer.Arrays['rows'].Count);
  Call('editor_properties', '{"selection": []}');
  AssertEquals('nothing', 'Nothing selected', Answer.Strings['title']);
end;

procedure TTestEditorServer.TestPointInputRows;

// The input rows of the named point, as "caption: text" separated by "; "
  function Inputs(const AName: string): string;
  var
    Rows: TJSONArray;
    Index: integer;
  begin
    Call('editor_properties', '{"selection": ["' + AName + '"]}');
    Rows := Answer.Arrays['rows'];
    Result := '';
    for Index := 0 to Rows.Count - 1 do
      if Copy(Rows.Objects[Index].Strings['id'], 1, 5) = 'input' then
      begin
        AssertEquals('read only', 'text', Rows.Objects[Index].Strings['kind']);
        if Result <> '' then
          Result := Result + '; ';
        Result := Result + Rows.Objects[Index].Strings['caption'] + ': ' + Rows.Objects[Index].Strings['text'];
      end;
  end;

var
  Rows: TJSONArray;
  Ids: string;
  Index: integer;
begin
  AddSquare;
  Call('add_point', '{"type": "offsetPoint", "name": "P", "base": "A", "mode": "cartesian", "dx": "10", "dy": "20"}');
  Call('add_point', '{"type": "alongEdgePoint", "name": "Q", "edge": "Line_A_B", "from": "end", "mode": "length", ' +
    '"value": "30"}');
  Call('add_point', '{"type": "betweenPoint", "name": "R", "a": "A", "b": "C", "mode": "ratio", "value": "0.5"}');
  Call('add_point', '{"type": "intersectPoint", "name": "S", "edgeA": "Line_A_B", "edgeB": "Line_B_C"}');
  Call('add_point', '{"type": "projectPoint", "name": "T", "point": "A", "edge": "Line_B_C", ' +
    '"direction": "perpendicular"}');
  AssertEquals('an offset', 'From: A', Inputs('P'));
  AssertEquals('along an edge', 'Along: Line_A_B', Inputs('Q'));
  AssertEquals('between', 'From: A; To: C', Inputs('R'));
  AssertEquals('a crossing', 'First edge: Line_A_B; Second edge: Line_B_C', Inputs('S'));
  AssertEquals('a projection', 'From: A; Onto: Line_B_C', Inputs('T'));
  AssertEquals('a free point has none', '', Inputs('A'));
  // After the name, before the formulas
  Call('editor_properties', '{"selection": ["P"]}');
  Rows := Answer.Arrays['rows'];
  Ids := '';
  for Index := 0 to Rows.Count - 1 do
    Ids := Ids + Rows.Objects[Index].Strings['id'] + ' ';
  AssertEquals('in order', 'type name locked input0 offsetMode dx dy marker markedOn result problem ', Ids);
  // Names follow a rename
  Call('rename', '{"name": "A", "newName": "Start"}');
  AssertEquals('renamed', 'From: Start', Inputs('P'));
end;

procedure TTestEditorServer.TestPropertyEdits;
var
  IdA, IdEdge: string;
begin
  AddSquare;
  IdA := IntToStr(IdOf('A'));
  // A line made a curve is named after its new type, so it is found by ID
  IdEdge := IntToStr(IdOf('Line_B_C'));
  Call('editor_property_set', '{"id": ' + IdA + ', "row": "name", "text": "Front"}');
  AssertTrue('renamed', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Rename', Answer.Strings['undo']);
  Call('editor_property_set', '{"id": ' + IdA + ', "field": "x", "text": "12 +"}');
  AssertFalse('refused', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['reason'] <> '');
  AssertTrue('and where', Answer.Integers['errorPos'] > 0);
  Call('editor_property_set', '{"id": ' + IdA + ', "field": "x", "text": "12 * 2"}');
  AssertTrue('a formula', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Change X', Answer.Strings['undo']);
  Call('get_object', '{"name": "Front"}');
  AssertEquals('moved', 24, Answer.Get('x', 0.0), TOLERANCE);
  Call('editor_property_set', '{"id": ' + IdA + ', "row": "marker", "value": 1}');
  AssertTrue('a hole', Answer.Booleans['done']);
  Call('editor_properties', '{"selection": [' + IdA + ']}');
  AssertTrue('its size shows', Assigned(PropertyRow('markerSize')));
  Call('editor_property_set', '{"id": ' + IdA + ', "row": "marker", "value": 9}');
  AssertFalse('no such marker', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdA + ', "row": "locked", "value": 1}');
  AssertTrue('locked', Answer.Booleans['done']);
  Call('editor_properties', '{"selection": [' + IdA + ']}');
  AssertTrue('shown locked', Answer.Booleans['locked']);
  Call('editor_property_set', '{"id": ' + IdA + ', "field": "x", "text": "5"}');
  AssertFalse('a locked point keeps its formulas', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['reason'] <> '');
  Call('editor_property_set', '{"id": ' + IdA + ', "row": "locked", "value": 0}');
  Call('editor_changes');
  AssertEquals('its step', 'Unlock', Answer.Strings['undo']);
  Call('editor_property_set', '{"id": ' + IdEdge + ', "row": "role", "value": 3}');
  AssertTrue('a stitch line', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Change role', Answer.Strings['undo']);
  Call('editor_property_set', '{"id": ' + IdEdge + ', "row": "type", "value": 1}');
  AssertTrue('a curve', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Change edge type', Answer.Strings['undo']);
  Call('editor_properties', '{"selection": [' + IdEdge + ']}');
  AssertEquals('a curve now', 1, PropertyRow('type').Integers['choice']);
  Call('editor_property_set', '{"id": ' + IdEdge + ', "row": "flip"}');
  AssertFalse('not a seam', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdEdge + ', "row": "nonsense", "value": 0}');
  AssertFalse('no such row', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdEdge + '}');
  AssertEquals('which row', RPC_INVALID_PARAMS, ErrorCode);
end;

// Measure by and Measured from: the point stays, its formula becomes a
// number, and each undo puts one change back
procedure TTestEditorServer.TestPointMeasurementEdits;
var
  PointId: string;
begin
  AddSquare;
  Call('add_point', '{"type":"alongEdgePoint","name":"Q","edge":"Line_A_B","from":"start","mode":"length","value":"10+15"}');
  PointId := IntToStr(IdOf('Q'));
  Call('editor_property_set', '{"id":' + PointId + ',"row":"measureMode","value":1}');
  AssertTrue('mode changed', Answer.Booleans['done']);
  Call('editor_property_set', '{"id":' + PointId + ',"row":"measureEnd","value":1}');
  AssertTrue('end flipped', Answer.Booleans['done']);
  Call('get_object', '{"name":"Q"}');
  AssertEquals(25.0, Answer.Floats['x'], 0.001);
  AssertEquals('0.75', Answer.Objects['formulas'].Strings['value']);
  Call('undo');
  Call('undo');
  Call('get_object', '{"name":"Q"}');
  AssertEquals('10+15', Answer.Objects['formulas'].Strings['value']);
end;

// Length and angle, or across and down: the point stays, its formulas become
// numbers, and one undo puts them back
procedure TTestEditorServer.TestOffsetModeEdit;
var
  IdP: string;
begin
  AddSquare;
  Call('add_point', '{"type": "offsetPoint", "name": "P", "base": "A", "mode": "cartesian", "dx": "15 * 2", "dy": "-40"}');
  IdP := IntToStr(IdOf('P'));
  Call('editor_properties', '{"selection": [' + IdP + ']}');
  AssertEquals('a choice', 'choice', PropertyRow('offsetMode').Strings['kind']);
  AssertEquals('across and down', 1, PropertyRow('offsetMode').Integers['choice']);
  AssertEquals('two ways', 2, PropertyRow('offsetMode').Arrays['choices'].Count);
  Call('editor_property_set', '{"id": ' + IdP + ', "row": "offsetMode", "value": 0}');
  AssertTrue('length and angle', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Change offset', Answer.Strings['undo']);
  Call('editor_properties', '{"selection": [' + IdP + ']}');
  AssertEquals('now length and angle', 0, PropertyRow('offsetMode').Integers['choice']);
  AssertEquals('a number', '50', PropertyRow('length').Strings['text']);
  AssertEquals('no across', 0, Pos('"dx"', Answer.Arrays['rows'].AsJSON));
  Call('get_object', '{"name": "P"}');
  AssertEquals('stays across', 30, Answer.Get('x', 0.0), 0.1);
  AssertEquals('and up', -40, Answer.Get('y', 0.0), 0.1);
  Call('undo');
  Call('editor_properties', '{"selection": [' + IdP + ']}');
  AssertEquals('its formula back', '15 * 2', PropertyRow('dx').Strings['text']);
  Call('editor_property_set', '{"id": ' + IdP + ', "row": "offsetMode", "value": 1}');
  AssertTrue('already so, nothing to do', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdP + ', "row": "offsetMode", "value": 2}');
  AssertFalse('no such mode', Answer.Booleans['done']);
end;

procedure TTestEditorServer.TestPiecePropertyEdits;
var
  IdPiece, Field: string;
begin
  AddSquare;
  IdPiece := IntToStr(IdOf('Flap'));
  Call('editor_properties', '{"selection": [' + IdPiece + ']}');
  AssertEquals('cut as a number', 'number', PropertyRow('cut').Strings['kind']);
  AssertEquals('cut once', 1, PropertyRow('cut').Get('value', 0.0), TOLERANCE);
  AssertEquals('at most', MAX_CUT_COUNT, PropertyRow('cut').Get('max', 0.0), TOLERANCE);
  AssertEquals('no fold and four straight edges', 5, PropertyRow('fold').Arrays['choices'].Count);
  AssertEquals('every edge can have its own', 5, PropertyRow('ownAllowance').Arrays['choices'].Count);
  AssertEquals('a new piece''s grainline is at an angle', 1, PropertyRow('grain').Integers['choice']);
  AssertEquals('its angle shown', 'formula', PropertyRow(GRAIN_ANGLE_FIELD).Strings['kind']);
  AssertFalse('its points wait', PropertyRow('grainFrom').Booleans['enabled']);
  AssertEquals('a colour', 'color', PropertyRow('fillColor').Strings['kind']);
  AssertEquals('from its material', '', PropertyRow('fillColor').Strings['text']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "cut", "number": 2}');
  AssertTrue('cut twice', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "cut", "number": 3}');
  Call('editor_changes');
  AssertEquals('its step', 'Change cut', Answer.Strings['undo']);
  Call('undo');
  Call('editor_properties', '{"selection": [' + IdPiece + ']}');
  AssertEquals('a run of counts is one step', 1, PropertyRow('cut').Get('value', 0.0), TOLERANCE);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "cut", "number": 2.5}');
  AssertFalse('a whole number', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "fold", "value": 1}');
  AssertTrue('folded', Answer.Booleans['done']);
  Call('editor_properties', '{"selection": [' + IdPiece + ']}');
  AssertEquals('on its first edge', 1, PropertyRow('fold').Integers['choice']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "ownAllowance", "value": 2}');
  AssertTrue('an edge of its own', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Add edge allowance', Answer.Strings['undo']);
  Call('editor_properties', '{"selection": [' + IdPiece + ']}');
  AssertEquals('one edge fewer to choose', 4, PropertyRow('ownAllowance').Arrays['choices'].Count);
  // The second edge's, with a row of its own
  Field := 'edge2.' + PIECE_ALLOWANCE_FIELD;
  AssertTrue('with a field', HasPropertyRow(Field));
  Call('editor_property_set', '{"id": ' + IdPiece + ', "field": "' + Field + '", "text": ""}');
  AssertTrue('emptied', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('goes back to the piece''s', 'Remove edge allowance', Answer.Strings['undo']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "grain", "value": 2}');
  AssertFalse('needs its points', Answer.Booleans['done']);
  // The points in the order they were added
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "grain", "value": 2, "from": 1, "to": 3}');
  AssertTrue('between two points', Answer.Booleans['done']);
  Call('editor_properties', '{"selection": [' + IdPiece + ']}');
  AssertEquals('between points', 2, PropertyRow('grain').Integers['choice']);
  AssertFalse('its points shown', Assigned(PropertyRow('grainFrom').Find('enabled')));
  AssertEquals('from A', 'A', PropertyRow('grainFrom').Arrays['choices'].Strings[PropertyRow('grainFrom').Integers['choice']]);
  AssertEquals('to C', 'C', PropertyRow('grainTo').Arrays['choices'].Strings[PropertyRow('grainTo').Integers['choice']]);
  AssertFalse('no angle', HasPropertyRow(GRAIN_ANGLE_FIELD));
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "grain", "value": 0}');
  Call('editor_changes');
  AssertEquals('its step', 'Change grainline', Answer.Strings['undo']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "fillColor", "text": "#ff0000"}');
  AssertTrue('its own colour', Answer.Booleans['done']);
  Call('editor_properties', '{"selection": [' + IdPiece + ']}');
  AssertEquals('kept', '#FF0000', PropertyRow('fillColor').Strings['text']);
  AssertEquals('drawn in it', '#FF0000', PropertyRow('fillColor').Strings['color']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "fillColor", "text": "red"}');
  AssertFalse('not a colour', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "fill", "value": 2}');
  AssertTrue('hatched', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdPiece + ', "row": "dart0", "value": 1}');
  AssertFalse('no darts', Answer.Booleans['done']);
end;

procedure TTestEditorServer.TestNotePropertyEdits;
var
  IdNote: string;
begin
  AddSquare;
  Call('add_note', '{"text": "Fold", "anchor": {"point": "A"}, "x": 10, "y": 20, "leader": "arrow"}');
  IdNote := IntToStr(Answer.Integers['id']);
  Call('editor_properties', '{"selection": [' + IdNote + ']}');
  AssertEquals('its text', 'Fold', PropertyRow('noteText').Strings['text']);
  AssertEquals('of several lines', 'longText', PropertyRow('noteText').Strings['kind']);
  AssertEquals('an arrow', 1, PropertyRow('noteLeader').Integers['choice']);
  AssertEquals('the default font', '', PropertyRow('noteFont').Strings['text']);
  AssertEquals('named', rsPropFontDefault, PropertyRow('noteFont').Arrays['choices'].Strings[0]);
  AssertEquals('its box''s caption', rsPropNoteBold, PropertyRow('noteBold').Strings['text']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteText", "text": "Fold\nhere\n"}');
  AssertTrue('two lines', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Change note text', Answer.Strings['undo']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteText", "text": "{=nothing.length}"}');
  AssertFalse('a draft value that does not parse', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['reason'] <> '');
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteSize", "number": 14}');
  AssertTrue('bigger', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteSize", "number": 900}');
  AssertFalse('too big', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteBold", "value": 1}');
  AssertTrue('bold', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('its step', 'Change note', Answer.Strings['undo']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteFont", "text": "DejaVu Serif"}');
  AssertTrue('a font', Answer.Booleans['done']);
  Call('editor_properties', '{"selection": [' + IdNote + ']}');
  AssertEquals('its font', 'DejaVu Serif', PropertyRow('noteFont').Strings['text']);
  AssertTrue('still bold', PropertyRow('noteBold').Booleans['checked']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteFont", "text": "' + rsPropFontDefault + '"}');
  Call('editor_properties', '{"selection": [' + IdNote + ']}');
  AssertEquals('the default again', '', PropertyRow('noteFont').Strings['text']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "notePrint", "value": 0}');
  AssertTrue('not printed', Answer.Booleans['done']);
  Call('editor_property_set', '{"id": ' + IdNote + ', "row": "noteFree"}');
  AssertTrue('free', Answer.Booleans['done']);
  Call('editor_properties', '{"selection": [' + IdNote + ']}');
  AssertFalse('nothing to point at', HasPropertyRow('noteLeader'));
  AssertFalse('nor to unhook', HasPropertyRow('noteFree'));
end;

const
  PERSONAL_SET = '{"format": "measurements", "version": 1, "units": "mm", "measurements": [' +
    '{"key": "waist", "value": 720, "description": "Waist"}]}';
  SIZE_TABLE = '{"format": "measurements", "version": 1, "units": "mm", "sizes": ["36", "38"], "measurements": [' +
    '{"key": "waist", "values": [700, 740]}]}';

function PointXOf(Server: TTestEditorServer; const AName: string): double;
begin
  Server.Call('get_object', '{"name": "' + AName + '"}');
  Result := Server.Answer.Get('x', 0.0);
end;

procedure TTestEditorServer.TestMeasurementEdits;
var
  Rows: TJSONArray;
  Key, Text: string;
begin
  Call('use_measurements', '{"text": "' + StringToJSONString(PERSONAL_SET) + '", "file": "me.slm"}');
  Answer;
  Call('add_point', '{"type": "freePoint", "name": "A", "x": "@waist / 4", "y": 0}');
  Answer;
  Call('set_measurement', '{"key": "waist", "value": 800}');
  AssertEquals('the API leaves a set given as text alone', RPC_REFUSED, ErrorCode);
  Call('editor_measurement_set', '{"key": "waist", "column": "value", "text": "eight"}');
  AssertFalse('not a number', Answer.Booleans['done']);
  AssertEquals(rsPanelBadValue, Answer.Strings['reason']);
  Call('editor_measurement_set', '{"key": "waist", "column": "value", "text": "800"}');
  AssertTrue('kept', Answer.Booleans['done']);
  Call('editor_measurement_set', '{"key": "waist", "column": "key", "text": "hip"}');
  AssertFalse('only a new key changes', Answer.Booleans['done']);
  AssertNear('not made yet', 180, PointXOf(Self, 'A'), TOLERANCE);
  Call('editor_measurement_add');
  Key := Answer.Strings['key'];
  AssertEquals('the first free key', 'measurement', Key);
  Call('editor_measurement_set', '{"key": "measurement", "column": "key", "text": "seat"}');
  AssertEquals('renamed', 'seat', Answer.Strings['key']);
  Call('editor_measurements_save');
  AssertFalse('seat has no value', Answer.Booleans['done']);
  Call('editor_measurement_set', '{"key": "seat", "column": "value", "text": "960.5"}');
  Call('editor_list_measurements');
  AssertEquals('two pending', 2, Answer.Integers['pendingCount']);
  AssertEquals('the file', 'me.slm', Answer.Strings['file']);
  Rows := Answer.Arrays['rows'];
  AssertEquals('the edit over the set', '800', Rows.Objects[0].Strings['value']);
  AssertTrue('marked', Rows.Objects[0].Booleans['pending']);
  AssertEquals('the new key last', 'seat', Rows.Objects[1].Strings['key']);
  AssertTrue('new', Rows.Objects[1].Booleans['isNew']);
  Call('editor_measurement_size', '{"size": "38"}');
  AssertEquals('not while edits wait', RPC_REFUSED, ErrorCode);
  Call('editor_measurements_save');
  AssertTrue('saved', Answer.Booleans['done']);
  Text := Answer.Strings['text'];
  AssertTrue('the file''s new text', (Pos('800', Text) > 0) and (Pos('seat', Text) > 0));
  AssertEquals('as recorded', 'me.slm', Answer.Strings['file']);
  AssertTrue('says so', Answer.Strings['message'] <> '');
  AssertNear('worked out again', 200, PointXOf(Self, 'A'), TOLERANCE);
  Call('editor_list_measurements');
  AssertEquals('none pending', 0, Answer.Integers['pendingCount']);
  Call('editor_measurement_set', '{"key": "waist", "column": "description", "text": "Natural waist"}');
  Call('editor_measurements_revert');
  Call('editor_list_measurements');
  AssertEquals('dropped', 0, Answer.Integers['pendingCount']);
  AssertEquals('as saved', 'Waist', Answer.Arrays['rows'].Objects[0].Strings['description']);
end;

procedure TTestEditorServer.TestMeasurementsNewSet;
begin
  Call('editor_measurement_add');
  Call('editor_measurement_set', '{"key": "measurement", "column": "value", "text": "500"}');
  Call('editor_measurements_save');
  AssertEquals('needs a name', RPC_INVALID_PARAMS, ErrorCode);
  Call('editor_measurements_save', '{"file": "sets/me.slm"}');
  AssertTrue('made', Answer.Booleans['done']);
  AssertEquals('as recorded', 'sets/me.slm', Answer.Strings['file']);
  AssertTrue('with the edit', Pos('500', Answer.Strings['text']) > 0);
  Call('editor_list_measurements');
  AssertEquals('the pattern records it', 'sets/me.slm', Answer.Strings['file']);
  AssertEquals('listed', 'measurement', Answer.Arrays['rows'].Objects[0].Strings['key']);
end;

procedure TTestEditorServer.TestMeasurementSizeAndScale;
begin
  Call('use_measurements', '{"text": "' + StringToJSONString(SIZE_TABLE) + '", "file": "block.slm"}');
  Answer;
  Call('add_point', '{"type": "freePoint", "name": "A", "x": "@waist / 4", "y": 0}');
  Call('editor_list_measurements');
  AssertEquals('sizes', 2, Answer.Arrays['sizes'].Count);
  AssertEquals('the first size', '36', Answer.Strings['size']);
  Call('editor_measurement_size', '{"size": "38"}');
  AssertEquals('used', '38', Answer.Strings['size']);
  AssertNear('that size', 185, PointXOf(Self, 'A'), TOLERANCE);
  Call('editor_measurement_size', '{"size": "99"}');
  AssertEquals('not in the table', RPC_REFUSED, ErrorCode);
  Call('editor_measurement_scale', '{"percent": 10}');
  AssertEquals('tried', 10, Answer.Integers['testPercent']);
  AssertNear('larger', 203.5, PointXOf(Self, 'A'), TOLERANCE);
  Call('editor_measurement_set', '{"key": "waist", "column": "value", "text": "760"}');
  AssertEquals('not while trying sizes', RPC_REFUSED, ErrorCode);
  Call('editor_measurement_scale', '{"percent": 50}');
  AssertEquals('kept within reach', 20, Answer.Integers['testPercent']);
  Call('editor_measurement_scale', '{"percent": 0}');
  Call('editor_measurement_set', '{"key": "waist", "column": "value", "text": "760"}');
  Call('editor_measurements_save');
  AssertTrue('saved to that size', Pos('760', Answer.Strings['text']) > 0);
  Call('editor_list_measurements');
  AssertEquals('still that size', '38', Answer.Strings['size']);
  AssertNear('the new value', 190, PointXOf(Self, 'A'), TOLERANCE);
end;

procedure TTestEditorServer.TestSuggestGraded;
var
  Items: TJSONArray;
  Item: TJSONObject;
  Index: integer;
begin
  Call('use_measurements', '{"text": "' + StringToJSONString(SIZE_TABLE) + '", "file": "block.slm"}');
  Answer;
  Call('add_point', '{"type": "freePoint", "name": "A", "x": 0, "y": 0}');
  Call('add_point', '{"type": "freePoint", "name": "B", "x": 175, "y": 0}');
  Call('add_edge', '{"type": "line", "start": "A", "end": "B", "role": "outline"}');
  Answer;
  Call('editor_suggest', '{"name": "B", "field": "x"}');
  AssertEquals('first and last sizes', '["36", "38"]', Answer.Arrays['sizes'].AsJSON);
  Items := Answer.Arrays['items'];
  Item := nil;
  for Index := 0 to Items.Count - 1 do
    if Items.Objects[Index].Strings['text'] = '@waist/4' then
      Item := Items.Objects[Index];
  AssertNotNull('a quarter waist is suggested', Item);
  AssertTrue('its range', Pos('185', Item.Strings['range']) > 0);
  AssertTrue('every size', Pos('38', Item.Strings['sizeValues']) > 0);
  Call('editor_suggest_preview', '{"name": "B", "field": "x", "text": "@waist/4", "value": 175}');
  AssertNear('the point would go', 175, Answer.Objects['position'].Floats['x'], TOLERANCE);
  AssertEquals('a ghost for each end of the table', 2, Answer.Arrays['ghosts'].Count);
  AssertNear('at the largest size', 185, Answer.Arrays['ghosts'].Objects[1].Arrays['point'].Floats[0], TOLERANCE);
  // Kept through a drag, which changes only the point
  Call('editor_drag_begin', '{"name": "B", "field": "x"}');
  Call('editor_drag_to', '{"x": 180, "y": 0}');
  Call('editor_suggest', '{"name": "B", "field": "x"}');
  AssertEquals('still graded', 2, Answer.Arrays['sizes'].Count);
  Call('editor_drag_cancel');
end;

procedure TTestEditorServer.TestSuggestRows;
begin
  AddSquare;
  Call('editor_properties', '{"selection": ["B"]}');
  AssertTrue('a number can be suggested for', PropertyRow('x').Get('suggest', False));
  Call('set_locked', '{"name": "B", "locked": true}');
  Call('editor_properties', '{"selection": ["B"]}');
  AssertFalse('not once locked', PropertyRow('x').Get('suggest', False));
  Call('editor_suggest_preview', '{"name": "B", "field": "x", "text": "1", "value": 1}');
  AssertEquals('refused', RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestNotePreview;
var
  IdNote: string;
begin
  AddSquare;
  Call('add_note', '{"text": "Fold", "x": 10, "y": 20}');
  IdNote := IntToStr(Answer.Integers['id']);
  Call('editor_note_preview', '{"id": ' + IdNote + ', "text": "Cut 2\nWidth {= 50 * 2} mm"}');
  AssertEquals('as typed, line by line', '["Cut 2", "Width 100 mm"]', Answer.Objects['note'].Arrays['lines'].AsJSON);
  AssertEquals('the same note', StrToInt(IdNote), Answer.Objects['note'].Integers['id']);
  Call('get_object', '{"id": ' + IdNote + '}');
  AssertEquals('unchanged', 'Fold', Answer.Strings['text']);
  Call('editor_note_preview', '{"name": "B", "text": "x"}');
  AssertEquals('only a note', RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestSnapshot;
begin
  Call('use_measurements', '{"text": "' + StringToJSONString(SIZE_TABLE) + '", "file": "block.slm"}');
  Answer;
  Call('add_point', '{"type": "freePoint", "name": "Spot", "x": "@waist / 4", "y": 0}');
  Answer;
  Call('editor_snapshot');
  AssertTrue('the pattern', Pos('"Spot"', Answer.Strings['text']) > 0);
  AssertEquals('its set as given', SIZE_TABLE, Answer.Strings['measurementsText']);
  AssertEquals('where the pattern records it', 'block.slm', Answer.Strings['measurementsFile']);
  AssertTrue('still unsaved', Answer.Booleans['modified']);
  Call('editor_changes');
  AssertTrue('not counted saved', Answer.Booleans['modified']);
  // The copy opens as the pattern it was
  Call('editor_snapshot');
  Call('open', '{"text": "' + StringToJSONString(Answer.Strings['text']) + '"}');
  AssertEquals('the measurement file it names', 'block.slm', Answer.Strings['measurementsFile']);
  Call('get_object', '{"name": "Spot"}');
  AssertEquals('the point kept', 'Spot', Answer.Strings['name']);
end;

procedure TTestEditorServer.TestSaveComplete;
var
  Revision: string;
begin
  AddSquare;
  Call('editor_snapshot');
  AssertTrue('snapshot leaves the pattern dirty', Answer.Booleans['modified']);
  Revision := IntToStr(Answer.Integers['revision']);
  Call('add_point', '{"type": "freePoint", "name": "Later", "x": 0, "y": 0}');
  Answer;
  Call('editor_save_complete', '{"revision": ' + Revision + '}');
  AssertTrue('a newer edit stays dirty', Answer.Booleans['modified']);
  Call('editor_snapshot');
  Revision := IntToStr(Answer.Integers['revision']);
  Call('editor_save_complete', '{"revision": ' + Revision + '}');
  AssertFalse('a write of the current snapshot marks it saved', Answer.Booleans['modified']);
  Call('editor_changes');
  AssertFalse('the editor sees the change', Answer.Booleans['modified']);
end;

procedure TTestEditorServer.TestMarkUnsaved;
begin
  AddSquare;
  Call('save', '{"text": true}');
  Call('editor_changes');
  AssertFalse('saved', Answer.Booleans['modified']);
  Call('editor_mark_unsaved');
  AssertTrue('the answer says so', Answer.Booleans['modified']);
  Call('editor_changes');
  AssertTrue('unsaved', Answer.Booleans['modified']);
  AssertEquals('the title changes', '["file"]', Answer.Arrays['changes'].AsJSON);
end;

function TTestEditorServer.FeatureField(const Id: string): TJSONObject;
var
  Index: integer;
  Fields: TJSONArray;
begin
  Fields := Answer.Arrays['fields'];
  for Index := 0 to Fields.Count - 1 do
    if Fields.Objects[Index].Strings['id'] = Id then
      Exit(Fields.Objects[Index]);
  Fail('No field ' + Id + ' in ' + Fields.AsJSON);
  Result := nil;
end;

function TTestEditorServer.FeatureValueOf(const Id: string): string;
var
  Index: integer;
  Values: TJSONArray;
begin
  Values := Answer.Arrays['values'];
  for Index := 0 to Values.Count - 1 do
    if Values.Objects[Index].Strings['id'] = Id then
      Exit(Values.Objects[Index].Strings['text']);
  Fail('No value ' + Id + ' in ' + Values.AsJSON);
  Result := '';
end;

procedure TTestEditorServer.TestFeatureForms;
var
  Values, Depth, Stitch: string;
begin
  AddSquare;
  Call('editor_features', '{"feature": "zip", "selection": []}');
  AssertEquals('every feature', 5, Answer.Arrays['features'].Count);
  AssertFalse('nothing to go along', Answer.Booleans['canApply']);
  AssertEquals('what to select', rsFeaturesChooseEdge, Answer.Strings['header']);
  AssertFalse('no ends to start from', FeatureField('from').Booleans['enabled']);
  AssertTrue('a length to start with', FeatureValueOf('length') <> '');
  AssertFalse('no shield but for a fly front', FeatureField('shield').Booleans['enabled']);
  Call('editor_features', '{"feature": "zip", "selection": ["Line_B_C"]}');
  AssertTrue('an edge', Answer.Booleans['canApply']);
  AssertEquals('along it', Format(rsFeaturesAlong, ['Line_B_C']), Answer.Strings['header']);
  AssertEquals('its ends', '["The B end", "The C end"]', FeatureField('from').Arrays['choices'].AsJSON);
  // A fly front, with its shield
  Values := Answer.Arrays['values'].AsJSON;
  Call('editor_features', '{"feature": "zip", "selection": ["Line_B_C"], "values": ' +
    StringReplace(Values, '"id" : "style", "text" : "0"', '"id" : "style", "text" : "3"', []) + ', "changed": "style"}');
  AssertTrue('a shield', FeatureField('shield').Booleans['enabled']);
  // A hem's topstitching follows its depth
  Call('editor_features', '{"feature": "hem", "selection": ["Line_C_D", "Line_D_A"]}');
  AssertEquals('both edges', Format(rsFeaturesAlong, ['Line_C_D, Line_D_A']), Answer.Strings['header']);
  Depth := FeatureValueOf('depth');
  Stitch := FeatureValueOf('stitch');
  Call('editor_features', '{"feature": "hem", "selection": [], "values": [{"id": "depth", "text": "50"}, ' +
    '{"id": "stitch", "text": "' + Stitch + '"}], "changed": "depth", "previous": "' + Depth + '"}');
  AssertEquals('3 mm short', '47', FeatureValueOf('stitch'));
  Call('editor_features', '{"feature": "pocket", "selection": []}');
  AssertEquals('no such feature', RPC_INVALID_PARAMS, ErrorCode);
end;

procedure TTestEditorServer.TestFeatureApply;
var
  Values: string;
begin
  AddSquare;
  Call('editor_features', '{"feature": "hem", "selection": ["Line_C_D"]}');
  Values := Answer.Arrays['values'].AsJSON;
  Call('editor_feature_apply', '{"feature": "hem", "selection": [], "values": ' + Values + '}');
  AssertFalse('nothing selected', Answer.Booleans['done']);
  AssertEquals('says what to select', rsFeaturesHemChoose, Answer.Strings['message']);
  Call('editor_feature_apply', '{"feature": "hem", "selection": ["Line_C_D"], "values": ' + Values + '}');
  AssertTrue('added', Answer.Booleans['done']);
  AssertEquals('says so', Format(rsFeaturesHemDone, ['Line_C_D']), Answer.Strings['message']);
  Call('editor_changes');
  AssertEquals('one step', rsFeaturesUndoHem, Answer.Strings['undo']);
  Call('editor_feature_apply', '{"feature": "dart", "selection": ["Line_A_B"], "values": [{"id": "width", "text": "0"}]}');
  AssertFalse('refused', Answer.Booleans['done']);
  AssertTrue('with the reason', Answer.Strings['message'] <> '');
  Call('editor_changes');
  AssertEquals('no step', rsFeaturesUndoHem, Answer.Strings['undo']);
end;

procedure TTestEditorServer.TestMaterials;
begin
  Call('editor_materials');
  AssertEquals('one to start with', 1, Answer.Arrays['rows'].Count);
  AssertEquals('named', 'Main', Answer.Arrays['rows'].Objects[0].Strings['name']);
  AssertEquals('tint or hatching', 2, Answer.Arrays['fills'].Count);
  AssertEquals('every fabric', 8, Answer.Arrays['fabrics'].Count);
  AssertEquals('the unit', 'mm', Answer.Strings['unit']);
  Call('editor_material_add');
  AssertEquals('added after it', 1, Answer.Integers['index']);
  Call('editor_material', '{"index": 1}');
  AssertTrue('a name of its own', Answer.Strings['name'] <> 'Main');
  AssertTrue('either may go now', Answer.Booleans['canDelete']);
  Call('editor_material_set', '{"index": 1, "field": "name", "text": "Lining"}');
  AssertTrue('renamed', Answer.Booleans['done']);
  Call('editor_changes');
  AssertEquals('one step', rsPanelRenameMaterial, Answer.Strings['undo']);
  Call('editor_material_set', '{"index": 1, "field": "color", "text": "blue"}');
  AssertFalse('not a colour', Answer.Booleans['done']);
  AssertEquals('says why', rsPanelBadColor, Answer.Strings['reason']);
  Call('editor_material_set', '{"index": 1, "field": "fill", "text": "hatch"}');
  Call('editor_material_set', '{"index": 1, "field": "width", "text": "1500"}');
  Call('editor_materials');
  AssertEquals('hatched', 'Hatching', Answer.Arrays['rows'].Objects[1].Strings['fillCaption']);
  AssertTrue('a roll', Pos('1500', Answer.Arrays['rows'].Objects[1].Strings['size']) > 0);
  Call('editor_material_set', '{"index": 1, "field": "colour", "text": "#000000"}');
  AssertEquals('no such field', RPC_INVALID_PARAMS, ErrorCode);
  Call('editor_material_delete', '{"index": 1}');
  AssertTrue('deleted', Answer.Booleans['done']);
  Call('editor_material_delete', '{"index": 0}');
  AssertFalse('the last stays', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['reason'] <> '');
  Call('editor_material', '{"index": 5}');
  AssertEquals('no such material', RPC_REFUSED, ErrorCode);
end;

procedure TTestEditorServer.TestExportDraft;
var
  Labelled, Unlabelled: string;
begin
  AddSquare;
  Call('editor_export_draft', '{"labels": ["' + IntToStr(IdOf('B')) + '"]}');
  Labelled := Answer.Strings['text'];
  AssertTrue('an SVG', Pos('<svg', Labelled) > 0);
  Call('editor_export_draft', '{"labels": []}');
  Unlabelled := Answer.Strings['text'];
  AssertTrue('the label written', Length(Labelled) > Length(Unlabelled));
end;

procedure TTestEditorServer.TestPrint;
var
  Pdf: string;
begin
  Call('editor_print');
  AssertFalse('nothing to print', Answer.Booleans['done']);
  AssertTrue('says why', Answer.Strings['reason'] <> '');
  AddSquare;
  Call('editor_print', '{"paper": "Letter", "fileName": "flap.sloper"}');
  AssertTrue('printed', Answer.Booleans['done']);
  Pdf := DecodeStringBase64(Answer.Strings['pdf']);
  AssertEquals('a PDF', '%PDF', Copy(Pdf, 1, 4));
  AssertTrue('on Letter paper', Pos('612', Pdf) > 0);
  Call('editor_changes');
  AssertTrue('nothing saved', Answer.Booleans['modified']);
  Call('editor_print', '{"paper": "A0"}');
  AssertEquals('no such paper', RPC_INVALID_PARAMS, ErrorCode);
end;

initialization
  RegisterTest(TTestEditorServer);

end.
