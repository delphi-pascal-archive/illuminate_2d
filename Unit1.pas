unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, ExtDlgs;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    GroupBox1: TGroupBox;
    TrackBar1: TTrackBar;
    GroupBox2: TGroupBox;
    TrackBar2: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    TrackBar3: TTrackBar;
    Label3: TLabel;
    TrackBar4: TTrackBar;
    Shape1: TShape;
    Image2: TImage;
    Button3: TButton;
    Button2: TButton;
    op: TOpenPictureDialog;
    Button4: TButton;
    Timer1: TTimer;
    Timer2: TTimer;
    Button6: TButton;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure defcor;
    procedure TrackBar2Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure AplicaLUT(Bmp: TBitmap);
    procedure Button5Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
  lx,ly,d,atual,aplic,cor: integer;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

type
  TCor24Bits = packed record
    R: byte; // Vermelho
    G: byte; // Verde
    B: byte; // Azul
  end;
  PCor24Bits = ^TCor24Bits;

  TLut = array [0..255] of Byte;

{$R *.DFM}

procedure TForm1.Timer2Timer(Sender: TObject);
begin
if trackbar1.position<trackbar1.max then
trackbar1.position:=trackbar1.position+50
else
begin
timer1.enabled:=true;
timer2.enabled:=false;
end;

end;

procedure tform1.defcor;
var
r1,g1,b1: integer; {atual}
r2,g2,b2: integer; {cor da luz}
r3,g3,b3: integer; {nova cor}
per,dif: integer;
begin
//porcentagem a ser aplicada
per:= round(100-((d*100)/trackbar1.position));
//RED
r1:= getrvalue(atual);
r2:= getrvalue(aplic);
if r2>=r1 then
r3:= round(r1 + (((r2-r1)*per)/100))
else
if r1>r2 then
r3:= round(r1 - (((r1-r2)*per)/100));
//GREEN
g1:= getgvalue(atual);
g2:= getgvalue(aplic);
if g2>=g1 then
g3:= round(g1 + (((g2-g1)*per)/100))
else
if g1>g2 then
g3:= round(g1 - (((g1-g2)*per)/100));
//BLUE
b1:= getbvalue(atual);
b2:= getbvalue(aplic);
if b2>=b1 then
b3:= round(b1 + (((b2-b1)*per)/100))
else
if b1>b2 then
b3:= round(b1 - (((b1-b2)*per)/100));
//UNIR
cor:= rgb(r3,g3,b3);
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
lx:= x;
ly:= y;
button4.click;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
form1.caption:= 'illuminate 2D - (' + inttostr(lx)+','+inttostr(ly)+')'+ ' - (' + inttostr(x)+','+inttostr(y)+')';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
lx:= 185;
ly:= 100;
cor:= clwhite;
aplic:= clwhite;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
shape1.Brush.color:= rgb(trackbar2.position,trackbar3.position,trackbar4.position);
aplic:= shape1.Brush.color;
button4.click;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
close;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
if op.execute then
begin
image1.picture.bitmap.LoadFromFile(op.filename);
image2.picture.bitmap.LoadFromFile(op.filename);
end;
end;

procedure Tform1.AplicaLUT(Bmp: TBitmap);
var
  pc:  PCor24Bits;
  a,b,x,y: Integer;
begin
  Bmp.PixelFormat := pf24bit;
  for y:=0 to Bmp.Height-1 do
  begin
    pc := Bmp.ScanLine[y];
    for x:=0 to Bmp.Width-1 do
    begin
   //b
   if lx>=x then
   b:= lx-x;
   if x>lx then
   b:= x-lx;
   if b<0 then b:=b*(-1);  {+}
   //a
   if ly>=y then
   a:= ly-y;
   if y>ly then
   a:= y-ly;
   if a<0 then a:=a*(-1);  {+}
   //d
   d:= round(sqrt( (a*a) + (b*b) ));   {int}
   if d<=trackbar1.position then   {se estiver dentro do raio}
   begin
   atual:= RGB(pc.b,pc.g,pc.r);{cor atual}
   defcor;
   pc.b:= getrvalue(cor);
   pc.g:= getgvalue(cor);
   pc.r:= getbvalue(cor);
   end;
      Inc(pc);
    end;
  end;
  image1.refresh;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
//limpa
image1.Picture:=image2.picture;
AplicaLUT(image1.picture.bitmap);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
button4.click;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
button4.click;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
if trackbar1.position>1 then
trackbar1.position:=trackbar1.position-50
else
begin
timer2.enabled:=true;
timer1.enabled:=false;
end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
if button6.caption='Pulse' then
begin
trackbar1.position:=100;
timer1.enabled:=true;
button6.caption:='Parar';
end
else
if button6.caption='Stop' then
begin
timer1.enabled:=false;
timer2.enabled:=false;
button6.caption:='Pulse';
end
end;

end.
