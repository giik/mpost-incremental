% MacOs only: Use the following shell command to process the file and open a
% single PDF called combined.pdf with all figures combined (one per page):
%
% BF=e && \
% mpost -interaction=nonstopmode "${BF}.mp" && \
% for OF in "${BF}"-*.ps; do ps2pdf "${OF}"; done && \
% rm -f combined.pdf "${BF}.log" mptextmp.mp *.mpx "${BF}"-*.ps && \
% ls -l ${BF}-*.pdf && \
% /usr/bin/automator CombineMetapostPDFs.workflow && \
% open -a Preview.app combined.pdf
%
input colorbrewer-rgb
input TEX

prologues := 3;
outputformat := "ps";
outputtemplate := "%j-%c.%o";

% Draw a point.
def cross_point(expr z) =
  begingroup
    save R;
    R = 1.0mm;
    save ll, ur, ul, lr;
    pair ll, ur, ul, lr;
    ll := z shifted ((down+left) scaled R);
    ur := z shifted ((up+right) scaled R);
    ul := z shifted ((up+left) scaled R);
    lr := z shifted ((down+right) scaled R);
    draw ul--lr withpen pencircle scaled 0.5pt;
    draw ll--ur withpen pencircle scaled 0.5pt;
  endgroup
enddef;

% Draw a grid.
vardef grid(expr b_box, g_unit) = save llx, lly, urx, ury, G;
  numeric llx, lly, urx, ury;
  (llx, lly) = llcorner b_box;
  (urx, ury) = urcorner b_box;
  picture G;
  G = image (
      for x = floor(llx / g_unit) + 1 upto floor(urx / g_unit):
      draw (x * g_unit, lly) -- (x * g_unit, ury);
    endfor
    for y = floor(lly / g_unit) + 1 upto floor(ury / g_unit):
      draw (llx, y * g_unit) -- (urx, y * g_unit);
    endfor
    ); G
enddef;

% The diameter of the circle.
D = 2R = 11cm;
% Fraction [0,1] of the circle where the AB line crosses to the left. Chosen
% between 0.5 (half) and 0.75 (three quarters) so the cross point is in the 3-rd
% quadrant.
f := 0.583;
% Angle (in degrees) by which to rotate the drawing counterclockwise. The
% graph-paper grid is not rotated.
alpha := 15;
% Cricle fraction (similar to f) by which to extend the circle arc past end
% points.
extend := 0.1;

% It is easier if we start with the circle and define everything using it.
path p[];
p0 := fullcircle scaled D;

% These are fractions of the circle path p0. 
%
% f1 and f2 are where AB crosses the circle.
f1 := 8f;
f2 := 8(3/4 - f + 3/4);
% f3 is diametrically opposed to f1.
f3 := 8f - 4;
% Extend the arc a bit past points f1 and f3 of p0.
f4 := f1 - extend;
f5 := f3 + extend;

% On the circle p0.
z2 = point f1 of p0;
z3 = point f2 of p0; % this is B of AB
z4 = point f3 of p0;
% Extend to the left to get A of AB.
z1 = z2 shifted (left scaled 1cm);
% The circular arc portion of p0..
p1 := subpath (f4, 8+f5) of p0;

z5 = point 6 of p0;

string s[];
s0 := "$A$";
s1 := "$B$";
s2 := "$O$";
s4 = "$C$";
s5 = "$D$";
s6 = "$C$";
s100 = "$\vbox{\hsize 2in \parindent 0pt \raggedright An extended caption.}$";
% & "label(TEX(\vbox{\hsize 2in \parindent 0pt \raggedright An extended caption.}), z0);";

vardef exportit(suffix p)(expr seq)(text scanned, caption) =
  picture pic;
  pic := p rotated alpha;
  path pbbox;
  pbbox := bbox(pic);
  pair shift;
  shift := origin - point 0 of pbbox;
  pic := pic shifted shift;
  picture from_scanned;
  from_scanned = image (
      scantokens(scanned);
    );
  addto pic also from_scanned;
  bboxmargin := 2.5mm;
  pbbox := bbox(pic);
  shift := shift + (origin - point 0 of pbbox);
  pic := pic shifted shift;

  pbbox := bbox(pic);

  picture shipped;
  shipped := nullpicture;
  addto shipped also grid(pbbox, 1mm) withcolor Greens 8 2;
  addto shipped also grid(pbbox, 10mm) withcolor Greens 8 3;
  addto shipped also pic;

  numeric llx, lly, lrx, lry;
  (llx, lly) = llcorner pbbox;
  (lrx, lry) = lrcorner pbbox;
  numeric w;
  w = floor(lrx-llx);
  show w;
  
  string s;
  s = "\hbox to " & str[w] & "pt{\vbox{\hsize " & str[w-10] & "pt \parindent0pt Figure " & str[seq] & ". " & caption & "}}";
  pair zcaption;
  zcaption = 0.5(llcorner shipped + lrcorner shipped);
  addto shipped also image (
      label.bot(TEX(s), zcaption shifted (down scaled 5 mm));
    );
  
  charcode := seq;
  shipout shipped;
enddef;

% Draw AB.
draw z1--z3 withpen pencircle scaled 1.15pt;
s10 := "label.llft(TEX(s0), z1 rotated alpha shifted shift);"
  & "label.lrt(TEX(s1), z3 rotated alpha shifted shift);";
exportit(currentpicture, 1, s10)("This is the original line segment $AB$.");
show zcaption;

% Show the circle center and radius and draw it.
cross_point(origin);
draw origin--z3 dashed evenly withcolor red withpen pencircle scaled 3/4;
draw p1;
s20 := s10 & "label.ulft(TEX(s2), origin rotated alpha shifted shift);" & "label.bot(TEX(s5), z2 rotated alpha shifted shift);";
exportit(currentpicture, 2, s20)("Pick a point $O$ not on $AB$ and construct the circle centered at $O$ through $B$. Label the intersection of the circle with $AB$ as $D$.");
show zcaption;

% Draw the diameter of the circle
draw z2--z4;
s30 := s20 & "label.urt(TEX(s6), z4 rotated alpha shifted shift);";
exportit(currentpicture, 3, s30)("Draw the diameter of the circle through $D$.");

% Draw BD_2
draw z3--z4;
exportit(currentpicture, 4, s30)("$CB$ is orthogonal to $AB$");

end.
