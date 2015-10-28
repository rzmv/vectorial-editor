unit main_unit;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
    ExtCtrls, Menus, ComCtrls, StdCtrls, DbCtrls, UTools, UFigures, UField, Math;

type

    { TDesk }

    TDesk = class(TForm)
        MainMenu: TMainMenu;
        FileMenu: TMenuItem;
        ExitMItem: TMenuItem;
        HelpMenu: TMenuItem;
        AboutMItem: TMenuItem;
        ToolMenu: TMenuItem;
        ShowAllItem: TMenuItem;
        PaintDesk: TPaintBox;
        XcoordinateText: TStaticText;
        YcoordinateText: TStaticText;
        ToolsBar: TToolBar;
        procedure AboutMItemClick(Sender: TObject);
        procedure ExitItemClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormPaint(Sender: TObject);
        procedure PaintDeskMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure PaintDeskMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
        procedure PaintDeskMouseUp(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
        procedure PaintDeskResize(Sender: TObject);
        procedure PanelBarButtonClick (Sender: TObject);
        procedure ShowAllItemClick(Sender: TObject);
        private
            IndexTool: integer;
            DrawContinue, IsMouseDown : boolean;
        public
            { public declarations }
    end;

var
    Desk: TDesk;

implementation

{$R *.lfm}

{ TDesk }


procedure TDesk.PaintDeskMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
begin
    if (ssLeft in Shift) and (IsMouseDown) then begin
        Tools[IndexTool].ToolMove(point(X,y));
        Invalidate;
    end;
end;

procedure TDesk.PaintDeskMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then begin
      IsMouseDown := False;
      Tools[IndexTool].SpecificAction(point(X,Y), PaintDesk.Width, PaintDesk.Height);
  end;
  Invalidate;
end;

procedure TDesk.PaintDeskResize(Sender: TObject);
begin
    ViewPort.PaintBoxResize(PaintDesk.Width / 2, PaintDesk.Height / 2);
end;


procedure TDesk.PanelBarButtonClick(Sender: TObject);
begin
    IndexTool:= (Sender as TToolButton).Tag;
    DrawContinue:= false;
end;

procedure TDesk.ShowAllItemClick(Sender: TObject);
begin
    ViewPort.ShowAll(PaintDesk.Width, PaintDesk.Height);
    Invalidate;
end;


procedure TDesk.AboutMItemClick(Sender: TObject);
begin
    ShowMessage('Разумов Максим, Б8103а, 2015 г.');
end;

procedure TDesk.ExitItemClick(Sender: TObject);
begin
    Close;
end;

procedure TDesk.FormCreate(Sender: TObject);
var
    button: TToolButton;
    i: integer;
begin
    IndexTool:= 0;
    ViewPort := TViewPort.Create(PaintDesk.Width / 2, PaintDesk.Height / 2);
    DrawContinue:= false;
    ViewPort.AddDisplacement(PaintDesk.Width / 2, PaintDesk.Height / 2);
    ToolsBar.Images := ToolsImages;
    IsMouseDown:= false;
    ShowAllItem.Enabled:= false;
    for i := 0 to High(Tools) do begin
        button := TToolButton.Create(self);
        button.Parent := ToolsBar;
        button.Tag := i;
        button.ImageIndex:= i;
        button.OnClick := @PanelBarButtonClick;
    end;
end;


procedure TDesk.FormPaint(Sender: TObject);
var
    figure: TFigure;
begin
    PaintDesk.Canvas.brush.style := bsClear;
    // вывод положения центра ViewPoint
    YcoordinateText.Caption:= FloatToStr(ViewPort.FCenter.y);
    XcoordinateText.Caption:= FloatToStr(ViewPort.FCenter.x);
    if (Length(Figures) > 0) then begin
       ShowAllItem.Enabled := true;
       ViewPort.FTopBoarder := Figures[0].FPoints[0].y;
       ViewPort.FBottomBoarder := Figures[0].FPoints[0].y;
       ViewPort.FLeftBoarder := Figures[0].FPoints[0].x;
       ViewPort.FRightBoarder := Figures[0].FPoints[0].x;
    end
    else
       ShowAllItem.Enabled := false;

    for figure in Figures do begin
        figure.Draw(PaintDesk.Canvas);
        ViewPort.FRightBoarder := max(ViewPort.FRightBoarder, figure.MaxX);
        ViewPort.FLeftBoarder := min(ViewPort.FLeftBoarder, figure.MinX);
        ViewPort.FTopBoarder := min(ViewPort.FTopBoarder, figure.MinY);
        ViewPort.FBottomBoarder := max(ViewPort.FBottomBoarder, figure.MaxY);
    end;
end;


procedure TDesk.PaintDeskMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
begin
    if (Button = mbLeft) then begin
        Tools[IndexTool].MakeActive(Point(X,y));
        DrawContinue:= true;
        IsMouseDown:= true;
    end
    else if (Button = mbRight) and (DrawContinue) then
        Tools[IndexTool].AdditionalAction(Point(X,y));

    if (Button = mbRight) and (Tools[IndexTool].FName = 'zoom') then
        Tools[IndexTool].AdditionalAction(Point(X,y));
    Invalidate;
end;

end.

