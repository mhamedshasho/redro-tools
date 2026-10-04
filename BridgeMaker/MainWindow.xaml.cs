using Microsoft.Win32;
using System.Globalization;
using System.Windows;
using System.Windows.Media;
using System.Windows.Shapes;
using System.Windows.Input;
namespace RedroBridgeMaker;
public partial class MainWindow : Window
{
    DocumentModel doc = new();
    double Scale=1;
    public MainWindow(){InitializeComponent();}
    double V(string s,double d)=>double.TryParse(s,NumberStyles.Float,CultureInfo.InvariantCulture,out var v)?v:d;
    void Draw(){
        Preview.Children.Clear(); if(doc.Paths.Count==0)return;
        var minX=doc.Paths.SelectMany(p=>p.Points).Min(p=>p.X); var minY=doc.Paths.SelectMany(p=>p.Points).Min(p=>p.Y);
        var maxX=doc.Paths.SelectMany(p=>p.Points).Max(p=>p.X); var maxY=doc.Paths.SelectMany(p=>p.Points).Max(p=>p.Y);
        var w=Math.Max(1,maxX-minX),h=Math.Max(1,maxY-minY); Scale=Math.Min(1000/w,620/h);
        foreach(var p in doc.Paths){for(int i=0;i<p.Segments.Count;i++){var s=p.Segments[i];var line=new Line{X1=(s.A.X-minX)*Scale,Y1=(maxY-s.A.Y)*Scale,X2=(s.B.X-minX)*Scale,Y2=(maxY-s.B.Y)*Scale,Stroke=Brushes.Black,StrokeThickness=1};Preview.Children.Add(line);}}
        foreach(var g in doc.Gaps){var a=g.A;var b=g.B;Preview.Children.Add(new Line{X1=(a.X-minX)*Scale,Y1=(maxY-a.Y)*Scale,X2=(b.X-minX)*Scale,Y2=(maxY-b.Y)*Scale,Stroke=Brushes.Red,StrokeThickness=3});}
        Preview.Width=w*Scale+20;Preview.Height=h*Scale+20;Status.Text=$"Paths: {doc.Paths.Count} | Bridges: {doc.Gaps.Count} | Scale: 1 mm = {Scale:0.##} px";
    }
    void Open_Click(object s,RoutedEventArgs e){var d=new OpenFileDialog{Filter="Vector files|*.pdf;*.eps;*.svg|All files|*.*"};if(d.ShowDialog()!=true)return;try{doc=VectorParser.Load(d.FileName);Draw();Status.Text=$"Loaded {System.IO.Path.GetFileName(d.FileName)}";}catch(Exception ex){MessageBox.Show(ex.Message,"Open failed",MessageBoxButton.OK,MessageBoxImage.Error);}}
    void Auto_Click(object s,RoutedEventArgs e){if(!doc.Paths.Any())return;doc.Gaps.Clear();BridgeEngine.Automatic(doc,V(BridgeLength.Text,5),V(StartOffset.Text,2),V(EndOffset.Text,2),V(Spacing.Text,100));Draw();}
    void Manual_Click(object s,RoutedEventArgs e){if(!doc.Paths.Any())return;var p=doc.Paths[0];var dist=V(Microsoft.VisualBasic.Interaction.InputBox("Distance from start (mm)","Manual Bridge","20"),20);BridgeEngine.AddAt(p,doc.Gaps,dist,V(BridgeLength.Text,5));Draw();}
    void Clear_Click(object s,RoutedEventArgs e){doc.Gaps.Clear();Draw();}
    void Export_Click(object s,RoutedEventArgs e){var d=new SaveFileDialog{Filter="SVG file|*.svg",FileName="bridged-output.svg"};if(d.ShowDialog()!=true)return;SvgExporter.Save(doc,d.FileName);Status.Text="Exported successfully.";}
}