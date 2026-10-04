using System.Text;
namespace RedroBridgeMaker;
static class SvgExporter
{
 public static void Save(DocumentModel d,string file){var minX=d.Paths.SelectMany(p=>p.Points).Min(p=>p.X);var minY=d.Paths.SelectMany(p=>p.Points).Min(p=>p.Y);var maxX=d.Paths.SelectMany(p=>p.Points).Max(p=>p.X);var maxY=d.Paths.SelectMany(p=>p.Points).Max(p=>p.Y);var sb=new StringBuilder($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{maxX-minX}mm\" height=\"{maxY-minY}mm\" viewBox=\"{minX} {minY} {maxX-minX} {maxY-minY}\">");foreach(var p in d.Paths)foreach(var s in p.Segments)sb.Append($"<line x1=\"{s.A.X}\" y1=\"{s.A.Y}\" x2=\"{s.B.X}\" y2=\"{s.B.Y}\" stroke=\"black\" fill=\"none\"/>");foreach(var g in d.Gaps)sb.Append($"<line x1=\"{g.A.X}\" y1=\"{g.A.Y}\" x2=\"{g.B.X}\" y2=\"{g.B.Y}\" stroke=\"white\" stroke-width=\"5\"/>");sb.Append("</svg>");File.WriteAllText(file,sb.ToString());}
}