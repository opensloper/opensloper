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

// The generated reference pages: committed copies that still match the
// program, and the command-line table the parser is built from.
unit Sloper.Tests.Docs;

{$mode ObjFPC}{$H+}

interface

uses
  fpcunit, testregistry, Sloper.Tests.TestCase;

type
  TTestDocs = class(TOSTestCase)
  published
    procedure TestCommittedPagesAreCurrent;
    procedure TestUnknownTopic;
    procedure TestPagesHaveDescriptions;
    procedure TestEveryFunctionListed;
    procedure TestParserHasEveryOption;
    procedure TestEveryCommandListed;
    procedure TestPythonClientHasEveryMethod;
    procedure TestPythonClientCreatesPatternFiles;
    procedure TestDocTextLinks;
    procedure TestExamplePatternsHaveNoProblems;
    procedure TestExampleDrapesSewEverySeam;
    procedure TestTutorialImagesDrawWhatExists;
  end;

implementation

uses
  SysUtils, Classes, ConsoleTools, Sloper.Core.JSON, Sloper.Core.Formula, Sloper.Core.Measurements, Sloper.Core.Pattern,
  Sloper.Core.PatternFile, Sloper.Core.PatternCheck, Sloper.CLI.Arguments, Sloper.Docs.Reference,
  Sloper.API.Methods, Sloper.Docs.Python, Sloper.Core.Units, Sloper.Core.DrapeFile, Sloper.Core.DrapeMesh, Sloper.Core.Piece;

function DocsFolder: string;
begin
  Result := ConcatPaths([ExtractFileDir(ExtractFileDir(ExpandFileName(ParamStr(0)))), 'docs']);
end;

function ReferenceFolder: string;
begin
  Result := ConcatPaths([DocsFolder, 'reference']);
end;

// Loads an example pattern with the measurement file it names, if any, and evaluates it
procedure LoadExample(const FileName: string; Pattern: TPattern; Measurements: TMeasurementSet);
var
  Err: string;
begin
  if not LoadPatternFromFile(Pattern, FileName, Err) then
    raise EAssertionFailedError.Create(FileName + ': ' + Err);
  if Pattern.MeasurementFile <> '' then
  begin
    if not Measurements.LoadFromFile(MeasurementFilePath(Pattern, FileName), Err) then
      raise EAssertionFailedError.Create(FileName + ': ' + Err);
    Pattern.Measurements := Measurements;
  end;
  Pattern.Evaluate;
end;

// Run ./opensloper-make.sh docs after ./opensloper-make.sh build to write them again
procedure TTestDocs.TestCommittedPagesAreCurrent;
var
  Topic, Expected, Committed, Err: string;
begin
  for Topic in DOC_TOPICS do
  begin
    AssertTrue(Topic, ReferencePage(Topic, Expected));
    AssertTrue(Err, ReadTextFile(ConcatPaths([ReferenceFolder, StringReplace(DocTopicPath(Topic), '/', PathDelim, [rfReplaceAll])]),
      Committed, Err));
    AssertEquals('docs/reference/' + DocTopicPath(Topic) + ' is out of date: run ./opensloper-make.sh build then ./opensloper-make.sh docs', Expected,
      Committed);
  end;
end;

procedure TTestDocs.TestUnknownTopic;
var
  Markdown: string;
begin
  AssertFalse(ReferencePage('nothing', Markdown));
  AssertEquals('', Markdown);
end;

// Every generated page opens with front matter giving its search description
procedure TTestDocs.TestPagesHaveDescriptions;
var
  Topic, Markdown: string;
begin
  for Topic in DOC_TOPICS do
    if DocTopicPath(Topic).EndsWith('.md') then
    begin
      AssertTrue(Topic, ReferencePage(Topic, Markdown));
      AssertTrue(Topic + ' starts with a description', Markdown.StartsWith('---'#10'description: "'));
      AssertTrue(Topic + ' closes its front matter before the title', Pos('"'#10'---'#10#10'# ', Markdown) > 0);
    end;
end;

procedure TTestDocs.TestEveryFunctionListed;
var
  Markdown: string;
  Info: TFormulaFunctionInfo;
begin
  AssertTrue(ReferencePage('functions', Markdown));
  for Info in FormulaFunctions do
    AssertTrue(Info.Name, Pos('`' + Info.Name + '(', Markdown) > 0);
end;

procedure TTestDocs.TestParserHasEveryOption;
var
  Parser: TArgumentParser;
  Option: TCliOption;
begin
  Parser := BuildCliParser;
  try
    for Option in CLI_OPTIONS do
      AssertNotNull(Option.Name, Parser.Options[Option.Name]);
  finally
    FreeAndNil(Parser);
  end;
end;

procedure TTestDocs.TestEveryCommandListed;
var
  Markdown: string;
  Command: TCliCommand;
begin
  AssertTrue(ReferencePage('cli', Markdown));
  for Command in CLI_COMMANDS do
    AssertTrue(Command.Name, Pos('### ' + Command.Name + #10, Markdown) > 0);
end;

procedure TTestDocs.TestDocTextLinks;
const
  URL = 'https://docs.opensloper.com/reference/';
begin
  AssertEquals('See formulas (' + URL + 'formulas/).', DocText('See [formulas](formulas.md).'));
  AssertEquals('A list[str], see formulas (' + URL + 'formulas/).',
    DocText('A list[str], see [formulas](formulas.md).'));
  AssertEquals('[x, y] or [a](b) then units (' + URL + 'units/)', DocText('[x, y] or [a](b) then [units](units.md)'));
  AssertEquals('Plain [text] only', DocText('Plain [text] only'));
end;

procedure TTestDocs.TestPythonClientHasEveryMethod;
var
  Python, Reserved: string;
  Method: TApiMethod;
begin
  AssertTrue(ReferencePage(PYTHON_CLIENT_TOPIC, Python));
  AssertEquals('opensloper.py', DocTopicPath(PYTHON_CLIENT_TOPIC));
  for Method in ApiMethods do
  begin
    AssertTrue(Method.Name, Pos('    def ' + Method.Name + '(', Python) > 0);
    AssertTrue(Method.Name, Pos('self._send("' + Method.Name + '"', Python) > 0);
    // The client's own methods keep their names
    for Reserved in PYTHON_CLIENT_RESERVED do
      AssertFalse(Method.Name + ' is a name the Python client uses', SameText(Method.Name, Reserved));
  end;
  // A target is sent as id or name, and members as given
  AssertTrue(Pos('return self._send("set_formula", _target(target), {', Python) > 0);
  AssertTrue(Pos('return self._send("add_point", members, {', Python) > 0);
  AssertTrue(Pos(#13, Python) = 0);
end;

// OpenSloper.create_pattern_file writes the version and offers the units the
// program has (issue #44)
procedure TTestDocs.TestPythonClientCreatesPatternFiles;
var
  Python, Units: string;
  AUnit: TMeasureUnit;
begin
  AssertTrue(ReferencePage(PYTHON_CLIENT_TOPIC, Python));
  Units := '';
  for AUnit := Low(TMeasureUnit) to High(TMeasureUnit) do
  begin
    if Units <> '' then
      Units := Units + ', ';
    Units := Units + '"' + MEASURE_UNIT_NAMES[AUnit] + '"';
  end;
  AssertTrue('a static method', Pos('    @staticmethod' + LineEnding + '    def create_pattern_file(', Python) > 0);
  AssertTrue('the current version', Pos(LineEnding + 'PATTERN_VERSION = ' + IntToStr(PATTERN_VERSION) + LineEnding, Python) > 0);
  AssertTrue('the units', Pos(LineEnding + 'PATTERN_UNITS = (' + Units + ')' + LineEnding, Python) > 0);
  AssertTrue('the units it takes', Pos('units: Literal[' + Units + '] = "mm",', Python) > 0);
  AssertTrue('the format', Pos('{"format": "' + PATTERN_FORMAT + '", "version": version, "units": units}', Python) > 0);
end;

// Every file under Folder, in its subfolders too, with this extension
procedure FindFiles(const Folder, Extension: string; Found: TStrings);
var
  Search: TSearchRec;
begin
  if FindFirst(ConcatPaths([Folder, AllFilesMask]), faAnyFile, Search) = 0 then
  try
    repeat
      if (Search.Name = '.') or (Search.Name = '..') then
        Continue;
      if (Search.Attr and faDirectory) <> 0 then
        FindFiles(ConcatPaths([Folder, Search.Name]), Extension, Found)
      else if SameText(ExtractFileExt(Search.Name), Extension) then
        Found.Add(ConcatPaths([Folder, Search.Name]));
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
end;

// Every tutorial and example pattern in docs/examples opens with its measurements, if it has any, and
// works out cleanly
procedure TTestDocs.TestExamplePatternsHaveNoProblems;
var
  Files: TStringList;
  FileName, Problem: string;
  Pattern: TPattern;
  Measurements: TMeasurementSet;
  Blocked: integer;
begin
  Files := TStringList.Create;
  try
    FindFiles(ConcatPaths([DocsFolder, 'examples']), '.sloper', Files);
    AssertTrue('there are examples', Files.Count > 0);
    for FileName in Files do
    begin
      Measurements := TMeasurementSet.Create;
      Pattern := TPattern.Create;
      try
        LoadExample(FileName, Pattern, Measurements);
        for Problem in PatternProblems(Pattern, Blocked) do
          Fail(ExtractFileName(FileName) + ': ' + Problem);
      finally
        FreeAndNil(Pattern);
        FreeAndNil(Measurements);
      end;
    end;
  finally
    FreeAndNil(Files);
  end;
end;

// Every example drape in docs/examples opens, places what it means to (the
// rest only waits), and leaves no seam open
procedure TTestDocs.TestExampleDrapesSewEverySeam;
var
  Files: TStringList;
  FileName, Err: string;
  Drape: TDrape;
  Problem: TDrapeProblem;
  Waiting: TStringList;
  Copy: TDrapePieceCopy;
  Piece: TPieceObject;
begin
  Files := TStringList.Create;
  Waiting := TStringList.Create;
  try
    FindFiles(ConcatPaths([DocsFolder, 'examples']), DRAPE_EXTENSION, Files);
    AssertTrue('there are drapes', Files.Count > 0);
    for FileName in Files do
    begin
      Drape := TDrape.Create;
      try
        AssertTrue(ExtractFileName(FileName) + ': ' + Err, Drape.LoadFromFile(FileName, Err));
        Drape.LoadSources;
        AssertTrue(ExtractFileName(FileName) + ': placed', Length(Drape.Items) > 0);
        Waiting.Clear;
        for Copy in Drape.Unplaced do
          if Drape.FindPiece(Copy, Piece) then
            Waiting.Add(Format(rsDrapeUnplaced, [ExtractFileName(Drape.FindSource(Copy.SourceId).PatternFile), Piece.DisplayName,
              Copy.Copy, Piece.CutCount]));
        for Problem in Drape.Problems do
          AssertTrue(ExtractFileName(FileName) + ': ' + Problem.Text, Waiting.IndexOf(Problem.Text) >= 0);
        for Problem in DrapeSeamProblems(Drape) do
          Fail(ExtractFileName(FileName) + ': ' + Problem.Text);
      finally
        FreeAndNil(Drape);
      end;
    end;
  finally
    FreeAndNil(Waiting);
    FreeAndNil(Files);
  end;
end;

// docs/tutorials/images.list names objects to draw up to; each must still exist
procedure TTestDocs.TestTutorialImagesDrawWhatExists;
var
  Lines: TStringList;
  Line, Err, Text: string;
  Parts: TStringArray;
  Pattern: TPattern;
  Measurements: TMeasurementSet;
begin
  AssertTrue(Err, ReadTextFile(ConcatPaths([DocsFolder, 'tutorials', 'images.list']), Text, Err));
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    for Line in Lines do
    begin
      if (Trim(Line) = '') or Line.StartsWith('#') then
        Continue;
      Parts := Line.Split([' '], TStringSplitOptions.ExcludeEmpty);
      AssertEquals(Line, 3, Length(Parts));
      AssertTrue(Parts[0] + ' is drawn', FileExists(ConcatPaths([DocsFolder, 'tutorials', 'images', Parts[0]])));
      if Parts[2] = '-' then
        Continue;
      Measurements := TMeasurementSet.Create;
      Pattern := TPattern.Create;
      try
        LoadExample(ConcatPaths([DocsFolder, Parts[1]]), Pattern, Measurements);
        AssertNotNull(Parts[0] + ': ' + Parts[2] + ' is not in ' + Parts[1], Pattern.FindObject(Parts[2]));
      finally
        FreeAndNil(Pattern);
        FreeAndNil(Measurements);
      end;
    end;
  finally
    FreeAndNil(Lines);
  end;
end;

initialization
  RegisterTest(TTestDocs);
end.
