using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace RedroBridgeMaker;

static class VectorParser
{
    static double N(string s) => double.Parse(s, CultureInfo.InvariantCulture);

    public static DocumentModel Load(string file) => System.IO.Path.GetExtension(file).ToLowerInvariant() switch
    {
        ".eps" => Eps(file),
        ".svg" => Svg(file),
        ".pdf" => Pdf(file),
        _ => throw new NotSupportedException("Use PDF, EPS or SVG.")
    };

    static DocumentModel Svg(string file)
    {
        var d = new DocumentModel();
        var x = XDocument.Load(file);
        foreach (var el in x.Descendants().Where(e => e.Name.LocalName == "path"))
        {
            var tokens = Regex.Matches((string?)el.Attribute("d") ?? "", @"[MLmlHhVvZz]|[-+]?(?:d+(?:.d*)?|.d+)(?:[eE][-+]?d+)?");
            var i = 0;
            var cx = 0.0;
            var cy = 0.0;
            PathModel? p = null;
            while (i < tokens.Count)
            {
                var cmd = tokens[i++].Value;
                if (cmd.Length != 1 || "MLmlHhVvZz".IndexOf(cmd[0]) < 0) continue;
                var c = cmd[0];
                if (c == 'Z' || c == 'z') { if (p != null) p.Closed = true; continue; }
                if (i + 1 >= tokens.Count) break;
                var a = N(tokens[i++].Value);
                var b = N(tokens[i++].Value);
                var nx = (c == 'm' || c == 'l') ? cx + a : a;
                var ny = (c == 'm' || c == 'l') ? cy + b : b;
                if (c == 'H' || c == 'h') { nx = c == 'h' ? cx + a : a; ny = cy; i--; }
                if (c == 'V' || c == 'v') { nx = cx; ny = c == 'v' ? cy + a : a; i--; }
                if (c == 'M' || c == 'm')
                {
                    p = new PathModel();
                    p.Points.Add(new Pt(nx, ny));
                    d.Paths.Add(p);
                }
                else if (p != null)
                {
                    var q = new Pt(nx, ny);
                    p.Segments.Add(new Seg(new Pt(cx, cy), q));
                    p.Points.Add(q);
                }
                cx = nx; cy = ny;
            }
        }
        return d;
    }

    static DocumentModel Eps(string file)
    {
        var d = new DocumentModel();
        var text = File.ReadAllText(file);
        var tok = Regex.Matches(text, @"[-+]?(?:d+(?:.d*)?|.d+)(?:[eE][-+]?d+)?|/[A-Za-z]+|[A-Za-z]+");
        var st = new Stack<double>();
        PathModel? p = null;
        var cur = new Pt(0, 0);
        foreach (Match m in tok)
        {
            if (double.TryParse(m.Value, NumberStyles.Float, CultureInfo.InvariantCulture, out var n)) { st.Push(n); continue; }
            var op = m.Value.TrimStart('/');
            if (op == "moveto" && st.Count >= 2)
            {
                var y = st.Pop(); var x = st.Pop();
                p = new PathModel(); cur = new Pt(x, y); p.Points.Add(cur); d.Paths.Add(p);
            }
            else if (op == "lineto" && st.Count >= 2 && p != null)
            {
                var y = st.Pop(); var x = st.Pop(); var q = new Pt(x, y);
                p.Segments.Add(new Seg(cur, q)); p.Points.Add(q); cur = q;
            }
            else if (op == "closepath" && p != null) p.Closed = true;
            else if (op == "newpath") p = null;
            else if (op == "curveto" && st.Count >= 6 && p != null)
            {
                var y3 = st.Pop(); var x3 = st.Pop();
                st.Pop(); st.Pop(); st.Pop(); st.Pop();
                var q = new Pt(x3, y3);
                p.Segments.Add(new Seg(cur, q)); p.Points.Add(q); cur = q;
            }
        }
        return d;
    }

    static DocumentModel Pdf(string file)
    {
        var d = new DocumentModel();
        var b = File.ReadAllBytes(file);
        var raw = Encoding.ASCII.GetString(b);
        foreach (Match m in Regex.Matches(raw, @"stream\r?\n(.*?)\r?\nendstream", RegexOptions.Singleline))
        {
            var s = m.Groups[1].Value;
            ParsePdfStream(s, d);
        }
        return d;
    }

    static void ParsePdfStream(string s, DocumentModel d)
    {
        var tok = Regex.Matches(s, @"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?|[A-Za-z]+");
        var st = new Stack<double>();
        PathModel? p = null;
        var cur = new Pt(0, 0);
        foreach (Match m in tok)
        {
            if (double.TryParse(m.Value, NumberStyles.Float, CultureInfo.InvariantCulture, out var n)) { st.Push(n); continue; }
            var op = m.Value;
            if (op == "m" && st.Count >= 2)
            {
                var y = st.Pop(); var x = st.Pop(); p = new PathModel(); cur = new Pt(x, y); p.Points.Add(cur); d.Paths.Add(p);
            }
            else if (op == "l" && st.Count >= 2 && p != null)
            {
                var y = st.Pop(); var x = st.Pop(); var q = new Pt(x, y);
                p.Segments.Add(new Seg(cur, q)); p.Points.Add(q); cur = q;
            }
            else if (op == "re" && st.Count >= 4)
            {
                var h = st.Pop(); var w = st.Pop(); var y = st.Pop(); var x = st.Pop();
                p = new PathModel();
                var a = new Pt(x, y); var b1 = new Pt(x + w, y); var c = new Pt(x + w, y + h); var e = new Pt(x, y + h);
                p.Points.AddRange(new[] { a, b1, c, e, a });
                p.Segments.AddRange(new[] { new Seg(a, b1), new Seg(b1, c), new Seg(c, e), new Seg(e, a) });
                p.Closed = true; cur = a; d.Paths.Add(p);
            }
            else if (op == "h" && p != null) p.Closed = true;
            else if (op == "c" && st.Count >= 6 && p != null)
            {
                var y3 = st.Pop(); var x3 = st.Pop();
                st.Pop(); st.Pop(); st.Pop(); st.Pop();
                var q = new Pt(x3, y3);
                p.Segments.Add(new Seg(cur, q)); p.Points.Add(q); cur = q;
            }
        }
    }
}