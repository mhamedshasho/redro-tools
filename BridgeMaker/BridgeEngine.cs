namespace RedroBridgeMaker;
static class BridgeEngine
{
 public static void Automatic(DocumentModel d,double len,double start,double end,double spacing){foreach(var p in d.Paths){var total=p.Segments.Sum(s=>Math.Hypot(s.B.X-s.A.X,s.B.Y-s.A.Y));if(total<start+end+len)continue;for(double at=start;at+len<=total-end;at+=spacing)AddAt(p,d.Gaps,at,len);}}
 public static void AddAt(PathModel p,List<Gap> gaps,double at,double len){double run=0;foreach(var s in p.Segments){var l=Math.Hypot(s.B.X-s.A.X,s.B.Y-s.A.Y);if(at>=run&&at<=run+l){var a=PointAt(s,at-run);var b=PointAt(s,Math.Min(l,at-run+len));gaps.Add(new Gap{A=a,B=b});return;}run+=l;}}
 static Pt PointAt(Seg s,double d){var l=Math.Hypot(s.B.X-s.A.X,s.B.Y-s.A.Y);var t=l==0?0:d/l;return new Pt(s.A.X+(s.B.X-s.A.X)*t,s.A.Y+(s.B.Y-s.A.Y)*t);}
}