using System.Globalization;
using System.Text;

namespace RedroBridgeMaker;

static class SvgExporter
{
    public static void Save(DocumentModel d, string file)
    {
        if (!d.Paths.Any()) throw new InvalidOperationException("No vector paths loaded.");
        var minX = d.Paths.SelectMany(p => p.Points).Min(p => p.X);
        var minY = d.Paths.SelectMany(p => p.Points).Min(p => p.Y);
        var maxX = d.Paths.SelectMany(p => p.Points).Max(p => p.X);
        var maxY = d.Paths.SelectMany(p => p.Points).Max(p => p.Y);
        var w = maxX - minX;
        var h = maxY - minY;
        var sb = new StringBuilder();
        sb.Append($"<svg xmlns="http://www.w3.org/2000/svg" width="{w.ToString(CultureInfo.InvariantCulture)}mm" height="{h.ToString(CultureInfo.InvariantCulture)}mm" viewBox="{minX.ToString(CultureInfo.InvariantCulture)} {minY.ToString(CultureInfo.InvariantCulture)} {w.ToString(CultureInfo.InvariantCulture)} {h.ToString(CultureInfo.InvariantCulture)}">");
        foreach (var p in d.Paths)
        {
            foreach (var s in p.Segments)
            {
                var dx = s.B.X - s.A.X;
                var dy = s.B.Y - s.A.Y;
                var l = Math.Sqrt(dx * dx + dy * dy);
                var gaps = d.Gaps.Where(g => DistanceToSegment(g.A, s) < 0.001 || DistanceToSegment(g.B, s) < 0.001).ToList();
                if (gaps.Count == 0)
                {
                    Line(sb, s.A, s.B);
                    continue;
                }
                var cuts = new List<(double t1, double t2)>();
                foreach (var g in gaps)
                {
                    var t1 = Projection(g.A, s);
                    var t2 = Projection(g.B, s);
                    var a = Math.Min(t1, t2); var b = Math.Max(t1, t2);
                    if (b > a) cuts.Add((Math.Clamp(a, 0, 1), Math.Clamp(b, 0, 1)));
                }
                var cursor = 0.0;
                foreach (var c in cuts.OrderBy(x => x.t1))
                {
                    if (c.t1 > cursor) Line(sb, Lerp(s.A, s.B, cursor), Lerp(s.A, s.B, c.t1));
                    cursor = Math.Max(cursor, c.t2);
                }
                if (cursor < 1) Line(sb, Lerp(s.A, s.B, cursor), s.B);
            }
        }
        sb.Append("</svg>");
        File.WriteAllText(file, sb.ToString(), Encoding.UTF8);
    }

    static double DistanceToSegment(Pt p, Seg s)
    {
        var dx = s.B.X - s.A.X; var dy = s.B.Y - s.A.Y;
        var den = dx * dx + dy * dy;
        if (den == 0) return Math.Sqrt(Math.Pow(p.X - s.A.X, 2) + Math.Pow(p.Y - s.A.Y, 2));
        var t = Math.Clamp(((p.X - s.A.X) * dx + (p.Y - s.A.Y) * dy) / den, 0, 1);
        var q = new Pt(s.A.X + dx * t, s.A.Y + dy * t);
        return Math.Sqrt(Math.Pow(p.X - q.X, 2) + Math.Pow(p.Y - q.Y, 2));
    }

    static double Projection(Pt p, Seg s)
    {
        var dx = s.B.X - s.A.X; var dy = s.B.Y - s.A.Y;
        var den = dx * dx + dy * dy;
        return den == 0 ? 0 : Math.Clamp(((p.X - s.A.X) * dx + (p.Y - s.A.Y) * dy) / den, 0, 1);
    }

    static Pt Lerp(Pt a, Pt b, double t) => new(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t);
    static void Line(StringBuilder sb, Pt a, Pt b) => sb.Append($"<line x1="{a.X.ToString(CultureInfo.InvariantCulture)}" y1="{a.Y.ToString(CultureInfo.InvariantCulture)}" x2="{b.X.ToString(CultureInfo.InvariantCulture)}" y2="{b.Y.ToString(CultureInfo.InvariantCulture)}" stroke="black" fill="none"/>");
}