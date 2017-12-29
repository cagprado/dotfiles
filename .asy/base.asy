// Asymptote module:
// Standardize generating figures (plots) with asymptote

import graph;
import stats;
import contour;
import palette;
import rootasy;

// {{{1 LaTeX configuration #################################################
// - Load default packages {{{2
usepackage("fontenc","T1");
usepackage("inputenc","utf8");
usepackage("newtxtext","p,osf");
usepackage("newtxmath");
usepackage("grffile");
usepackage("amsmath,amssymb,mathtools,slashed,siunitx,bm");
// }}}2
// - LaTeX preamble {{{2
private string texpreambletext = "";
texpreambletext += "\sisetup{";
texpreambletext += "  detect-all,";
texpreambletext += "  detect-mode=false,";
texpreambletext += "  mode=text,";
texpreambletext += "  text-rm=\lfstyle,";
texpreambletext += "  text-sf=\lfstyle,";
texpreambletext += "  text-tt=\lfstyle,";
texpreambletext += "  }";
texpreambletext += "\DeclareSIUnit{\fm}{\femto\metre}";
texpreambletext += "\providecommand\bm[1]{\bm{#1}}";
texpreambletext += "\newcommand\romanup[1]{\text{#1}}";
texpreambletext += "\newcommand\greekup[1]{{#1}}";
texpreambletext += "\InputIfFileExists{../tex/definitions.tex}{}{}";
// }}}2
// - Redefine font size commands {{{2
private pair[] fontsizes = {
  ( 7.00,  8.00), // tiny
  ( 8.00,  9.50), // scriptsize
  ( 9.00, 11.00), // footnotesize
  (10.00, 12.00), // small
  (10.95, 13.60), // normalsize
  (12.00, 14.50), // large
  (14.40, 18.00), // Large
  (17.28, 22.00), // LARGE
  (20.74, 25.00), // huge
  (24.88, 30.00), // Huge
};

// create texpreamble redefining the font sizes
private string[] fontsizenames = { "\tiny", "\scriptsize", "\footnotesize",
  "\small", "\normalsize", "\large", "\Large", "\LARGE", "\huge", "\Huge" };
for (int i = 0; i < fontsizes.length; ++i)
  texpreambletext += "\renewcommand" + fontsizenames[i] + "{\fontsize{"
    + format("%f",fontsizes[i].x) + "}{"
    + format("%f",fontsizes[i].y) + "}\selectfont}"
    + '\n';
texpreamble(texpreambletext);

// define pens for font sizes
restricted pen tiny         = fontsize(fontsizes[0].x, fontsizes[0].y);
restricted pen scriptsize   = fontsize(fontsizes[1].x, fontsizes[1].y);
restricted pen footnotesize = fontsize(fontsizes[2].x, fontsizes[2].y);
restricted pen small        = fontsize(fontsizes[3].x, fontsizes[3].y);
restricted pen normalsize   = fontsize(fontsizes[4].x, fontsizes[4].y);
restricted pen large        = fontsize(fontsizes[5].x, fontsizes[5].y);
restricted pen Large        = fontsize(fontsizes[6].x, fontsizes[6].y);
restricted pen LARGE        = fontsize(fontsizes[7].x, fontsizes[7].y);
restricted pen huge         = fontsize(fontsizes[8].x, fontsizes[8].y);
restricted pen Huge         = fontsize(fontsizes[9].x, fontsizes[9].y);
//Label operator+(pen p, string s) { return Label(s,p); }
//Label operator+(string s, pen p) { return Label(s,p); }
// }}}2
// }}}1
// {{{1 Pen configuration ###################################################
// - Color palettes {{{2
pen trueblack = rgb("000000");
pen hepic  = rgb("6d6e70");
pen black  = rgb("4d4d4d");
pen red    = rgb("c82829");
pen blue   = rgb("4271ae");
pen purple = rgb("8959a8");
pen orange = rgb("f5871f");
pen green  = rgb("718c00");
pen cyan   = rgb("3e999f");
pen yellow = rgb("eab700");
pen gray   = rgb("8e908c");

pen defaultcolor()
{ // get color of defaultpen
  pen p;
  string space = colorspace(p);
  real[] colors = colors(p);
  if (space == "gray") return gray(colors[0]);
  else if (space == "rgb") return rgb(colors[0], colors[1], colors[2]);
  else if (space == "cmyk") return cmyk(colors[0], colors[1], colors[2], colors[3]);
  else return invisible;
}

private typedef pen color();
pen operator cast(color p) { return p(); }
restricted color[] color = {
  new pen() { return defaultcolor(); },
  new pen() { return red; },
  new pen() { return blue; },
  new pen() { return green; },
  new pen() { return orange; },
  new pen() { return purple; },
  new pen() { return cyan; },
  new pen() { return yellow; },
  new pen() { return gray; },
};
color.cyclic = true;
// }}}2
// - Color gradients {{{2
//   - CIE L*a*b {{{3
// Conversion from rgb to CIE L*a*b is device dependent so this is probably
// not really correct.  This conversion is based in Chroma.js code:
// https://github.com/gka/chroma.js
private struct lab {
  // CIE L*a*b colorspace
  restricted real l, a, b;
  private static real K = 18;
  private static real X = 0.950470;
  private static real Y = 1;
  private static real Z = 1.088830;

  private real rgb_xyz(real r) {
    if (r <= 0.04045)
      return r/12.92;
    else
      return ((r + 0.055)/1.055) ^ 2.4;
  }

  private real xyz_rgb(real r) {
    if (r <= 0.00304)
      return 12.92*r;
    else
      return 1.055 * r^(1/2.4) - 0.055;
  }

  private real xyz_lab(real x) {
    if (x > 0.008856)
      return x ^ (1./3.);
    else
      return 7.787037 * x + 4. / 29.;
  }

  private real lab_xyz(real x) {
    if (x > 0.206893034)
      return x*x*x;
    else
      return (x - 4./29.) / 7.787037;
  }

  private real[] rgb2xyz(real[] rgb) {
    real r = rgb_xyz(rgb[0]);
    real g = rgb_xyz(rgb[1]);
    real b = rgb_xyz(rgb[2]);
    real x = xyz_lab((0.4124564*r + 0.3575761*g + 0.1804375*b)/X);
    real y = xyz_lab((0.2126729*r + 0.7151522*g + 0.0721750*b)/Y);
    real z = xyz_lab((0.0193339*r + 0.1191920*g + 0.9503041*b)/Z);
    return new real[] {x,y,z};
  }

  void operator init(real l, real a, real b) {
    this.l = l;
    this.a = a;
    this.b = b;
  }

  void operator init(pen p) {
    real[] xyz = rgb2xyz(colors(rgb(p)));
    real x = xyz[0];
    real y = xyz[1];
    real z = xyz[2];
    this.l = 116*y - 16;
    this.a = 500*(x - y);
    this.b = 200*(y - z);
  }

  pen rgb() {
    real y = (this.l + 16) / 116;
    real x = y + this.a / 500;
    real z = y - this.b / 200;
    x = lab_xyz(x) * X;
    y = lab_xyz(y) * Y;
    z = lab_xyz(z) * Z;
    real r = xyz_rgb( 3.2404542*x - 1.5371385*y - 0.4985314*z);
    real g = xyz_rgb(-0.9692660*x + 1.8760108*y + 0.0415560*z);
    real b = xyz_rgb( 0.0556434*x - 0.2040259*y + 1.0572252*z);
    r = (r<0) ? 0 : (r>1) ? 1 : r;
    g = (g<0) ? 0 : (g>1) ? 1 : g;
    b = (b<0) ? 0 : (b>1) ? 1 : b;
    return rgb(r,g,b);
  }
}

// Convert CIE L*a*b to rgb space
pen operator cast(lab lab)
{
  return lab.rgb();
}

// Convert pen to CIE L*a*b space
lab operator cast(pen p)
{
  return lab(p);
}

// Convert array of pens to CIE L*a*b space
lab[] operator cast(pen[] pens)
{
  lab[] lab;
  for (pen p : pens)
    lab.push(lab(p));
  return lab;
}

// Get array of values for CIE L*a*b colorspace
real[] colors(lab c)
{
  return new real[] { c.l, c.a, c.b };
}
// }}}3
//   - Gradient interpolation {{{3
private typedef lab interpolator(real);
private interpolator bezier_interpolator(lab[] colors)
{
  interpolator I;
  if (colors.length == 2) { // linear
    I = new lab (real t) {
      real l,a,b;
      l = colors[0].l + t*(colors[1].l - colors[0].l);
      a = colors[0].a + t*(colors[1].a - colors[0].a);
      b = colors[0].b + t*(colors[1].b - colors[0].b);
      return lab(l,a,b);
    };
  }
  else if (colors.length == 3) { // quadratic
    I = new lab (real t) {
      real l,a,b;
      l = (1-t)^2 * colors[0].l + 2*(1-t)*t * colors[1].l + t^2 * colors[2].l;
      a = (1-t)^2 * colors[0].a + 2*(1-t)*t * colors[1].a + t^2 * colors[2].a;
      b = (1-t)^2 * colors[0].b + 2*(1-t)*t * colors[1].b + t^2 * colors[2].b;
      return lab(l,a,b);
    };
  }
  else if (colors.length == 4) { // cubic
    I = new lab (real t) {
      real l,a,b;
      l = (1-t)^3 * colors[0].l + 3*(1-t)^2*t * colors[1].l + 3*(1-t)*t^2 * colors[2].l + t^3 * colors[3].l;
      a = (1-t)^3 * colors[0].a + 3*(1-t)^2*t * colors[1].a + 3*(1-t)*t^2 * colors[2].a + t^3 * colors[3].a;
      b = (1-t)^3 * colors[0].b + 3*(1-t)^2*t * colors[1].b + 3*(1-t)*t^2 * colors[2].b + t^3 * colors[3].b;
      return lab(l,a,b);
    };
  }
  else if (colors.length == 5) {
    interpolator I0 = bezier_interpolator(colors[0:3]);
    interpolator I1 = bezier_interpolator(colors[2:5]);
    I = new lab (real t) {
      if (t < 0.5)
        return I0(2*t);
      else
        return I1(2*(t-0.5));
    };
  }
  return I;
}

private typedef real correction(real);
private correction mapscale(interpolator I)
{
  real L0 = I(0).l;
  real L1 = I(1).l;
  bool pol = L0 > L1;

  return new real (real t) {
    real L_ideal = L0 + (L1 - L0)*t;
    real L_actual = I(t).l;
    real L_diff = L_actual - L_ideal;

    real t0 = 0, t1 = 1;
    int max_iter = 20;
    while (abs(L_diff) > 1e-9 && --max_iter > 0) {
      if (pol) L_diff *= -1;
      if (L_diff < 0) {
        t0 = t;
        t += (t1 - t)*0.5;
      }
      else {
        t1 = t;
        t += (t0 - t)*0.5;
      }
      L_actual = I(t).l;
      L_diff = L_actual - L_ideal;
    }

    return t;
  };
}

pen[] reverse(pen[] p)
{
  pen[] r;
  int n = p.length;
  for (int i = 0; i < n; ++i)
    r.push(p[n-1-i]);
  return r;
}

pen[] LabGradient(int n = 500, bool correct = true, pen[] p)
{
  interpolator I = bezier_interpolator(p);
  correction map = correct ? mapscale(I) : new real(real t) { return t; };

  pen[] scale;
  for (int i = 0; i < n; ++i)
    scale.push(I(map(i/(n-1))));
  return scale;
}

pen[] LabGradient(int n = 500, bool correct = true ... pen[] p)
{
  return LabGradient(n, correct, p);
}

pen[] Monochrome(int n = 500, bool correct = true, pen p)
{
  return LabGradient(n, correct, rgb("000000"), p, 2*p, rgb("ffffff"));
}

pen[] Divergent(int n = 500, real ratio = 0.5, bool symmetric = true, bool correct = true ... pen[] p)
{
  if (p.length == 0)
    warning("Divergent", "Divergent needs at least three pens...");

  pen[] lo = p[:floor((1+p.length)/2)];
  pen[] hi = p[floor((p.length)/2):];

  pen[] loscale, hiscale, finalscale;
  if (symmetric) {
    if (ratio < 0.5) {
      int m = floor((1-ratio)*n);
      loscale = LabGradient(m, correct, lo)[m-ceil(ratio*n):];
      hiscale = LabGradient(m, correct, hi);
    }
    else {
      int m = floor(ratio*n);
      loscale = LabGradient(m, correct, lo);
      hiscale = LabGradient(m, correct, hi)[:ceil((1-ratio)*n)];
    }
  }
  else {
    loscale = LabGradient(floor(ratio*n), correct, lo);
    hiscale = LabGradient(ceil((1-ratio)*n), correct, hi);
  }
  finalscale = loscale;
  finalscale.append(hiscale);
  return finalscale;
}
// }}}3
restricted pen[][] gradient = {
  LabGradient(rgb("222288"), rgb("005599"), rgb("00aacc"), rgb("00ff99"), rgb("ffffc0")),
  LabGradient(rgb("000000"), rgb("ff0000"), rgb("ffdd00"), rgb("ffffff")),
  Divergent(rgb("0066dd"), rgb("00ccaa"), rgb("ffffff"), rgb("ffcc00"), rgb("ff2200")),
  Divergent(rgb("333399"), rgb("0055ff"), rgb("ffffff"), rgb("ffff33"), rgb("44bb33")),
  Rainbow(),
  Grayscale(),
};
pen[] currentgradient = gradient[0];
// }}}2
// - Line styles {{{2
restricted pen[] lstyle = {
  linecap(0)+linetype(new real[]),                               // ───────────
  linecap(0)+linetype(new real[] {5,3}, 0, false, true),         // ── ── ── ──
  linecap(0)+linetype(new real[] {10,3}, 0, false, true),        // ───── ─────
  linecap(0)+linetype(new real[] {10,3,4,3}, 0, false, true),    // ─── ─ ─── ─
  linecap(0)+linetype(new real[] {7,2,1,2}, 0, false, true),     // ──── · ────
  linecap(0)+linetype(new real[] {8,2,1,2,1,2}, 0, false, true), // ─── · · ───
  linecap(1)+linetype(new real[] {0,2.3}, 0, true, true),        // ···········
  linecap(1)+linetype(new real[] {0,4.6}, 0, true, true),        // · · · · · ·
};
lstyle.cyclic = true;
solid = lstyle[0];
dashed = lstyle[1];
dotted = lstyle[-2];
Dotted = lstyle[-1];

// regardless of pen used, dot need round cap and solid type to be visible
private void plain_dot(frame, pair, pen, filltype) = dot;
dot = new void(frame f, pair z, pen p=currentpen, filltype filltype=Fill)
  { plain_dot(f,z,p+solid+linecap(1),filltype); };
// }}}2
// {{{2 - Markers
real markerfactor;
restricted typedef marker mstyle(real s = markerfactor, pen p = currentpen, pen f = white);
restricted marker operator cast(mstyle mstyle) { return mstyle(); }

restricted marker operator+(marker a, marker b)
{ // append marker 'b' on top of 'a'
  marker m = new marker;
  add(m.f, a.f);
  add(m.f, b.f);
  m.above = b.above;
  m.markroutine = b.markroutine;
  return m;
}

path star(int n, int m = 2)
{ // regular star polygon denoted by its Schläfli symbol {n/m}
  path p1 = polygon(n);
  path p2 = scale(cos(pi*m/n)/cos(pi*(m-1)/n))*rotate(180/n)*polygon(n);
  guide g;
  for (int i = 0; i < n; ++i)
    g = g--point(p1,i)--point(p2,i);
  return g--cycle;
}

restricted mstyle mstyle[] = {
  // ● ■ ▲ ★ × + ✳ , then open version (in reverse order)
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s)*unitcircle, Fill(p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*polygon(4), Fill(p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*polygon(3), Fill(p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*star(5), Fill(p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*cross(4), p); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*rotate(45)*cross(4), p); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*cross(6), p); },

  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*cross(6,false,0.4), FillDraw(f,p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*rotate(45)*cross(4,false,0.4), FillDraw(f,p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*cross(4,false,0.4), FillDraw(f,p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*star(5), FillDraw(f,p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*polygon(3), FillDraw(f,p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s/0.85)*polygon(4), FillDraw(f,p)); },
  new marker(real s = markerfactor, pen p = currentpen, pen f = white) { return marker(scale(s)*unitcircle, FillDraw(f,p)); },
};
mstyle.cyclic = true;
restricted marker merror(real s = markerfactor, pen p = currentpen, pen f = white) { frame F; draw(F, scale(3mm)*((-0.5,0)--(0.5,0)), p, Bars(s*2.3)); return marker(F); }
// }}}2
dotfactor = 6;
arrowfactor = 10;
markerfactor = 2.5;
defaultpen(1+lstyle[0]+trueblack+normalsize);
// }}}1
// {{{1 Legend configuration ################################################
// - definitions {{{2
// empty item
Legend empty = Legend("",invisible);

// redefine legend to use invisible border by default
frame plain_legend(picture, int, real, real, real, real, real, real, real,
  bool, bool, pen) = legend;
void legend(picture pic=currentpicture, int perline=1, real xmargin=legendmargin,
  real ymargin=xmargin, real linelength=legendlinelength, real hskip=legendhskip,
  real vskip=legendvskip, real maxwidth=perline == 0 ?  legendmaxrelativewidth*size(pic).x : 0,
  real maxheight=0, bool hstretch=false, bool vstretch=false, pair position,
  pair align=0, pen plabel=currentpen+footnotesize, pen pborder=invisible, filltype
  filltype=NoFill)
{
  // normalize text color (asymptote uses same as line, as default)
  for (int i = 0; i < pic.legend.length; ++i)
    pic.legend[i].plabel = plabel;

  // add legend
  add(pic, plain_legend(pic, perline, xmargin, ymargin, linelength, hskip,
    vskip, maxwidth, maxheight, hstretch, vstretch, pborder), position,
    align, filltype);
};

void legendpush(picture pic = currentpicture, Legend item)
{
  pic.legend.push(item);
}

void legendpush(picture pic = currentpicture, string label, pen plabel = invisible, marker mark = null, bool above = true)
{
  legendpush(pic, Legend(label, plabel, mark != null ? mark.f : newframe, above));
}

void legenddelete(picture pic = currentpicture)
{
  pic.legend.delete();
}
// }}}2
legendmargin = 1.5mm;
legendlinelength = 6mm;
legendhskip = 1.0;
legendvskip = 0.9;
// }}}1
// {{{1 Picture/pages management ############################################
// - pages {{{2
private void plain_newpage(picture) = newpage;
private picture finalpicture;
private struct Pages
{
  picture page;                             // page current being drawn
  restricted pair size = (16*45mm/9, 45mm); // grid size in the page

  // update page unitsize() using the grid size
  void update() { unitsize(this.page, size.x, size.y); }

  // set grid size in the page
  void gridsize(real x, real y)
  {
    this.size = (x, y);
    this.update();
  }

  // finish page and adds new page to pic
  void newpage(picture pic)
  {
    // if page is not empty, add it
    if (!this.page.empty()) {
      if (!pic.empty()) plain_newpage(pic);
      transform t = this.page.calculateTransform() * shift(-point(this.page, 0));
      add(pic, this.page.fit(t), 0);

      // setup new page
      this.page = new picture;
      this.update();
    }
  }
};
private Pages pages;
pages.update();
// }}}2
// - panels {{{2
private void plain_size(picture pic = currentpicture, real, real, bool) = size;
private struct Panel
{
  bool haslimits = false;
  pair position = (0,0);
  pair origin = (0.5,0.5);
  pair size = pages.size;
  bool aspect = false;
  bool center = false;
  bool fixed = true;

  // set size of the panel
  void size(picture pic = currentpicture, real x, real y, bool keepAspect, bool center, bool fixed)
  {
    this.size = (x,y);
    this.aspect = keepAspect;
    this.center = center;
    this.fixed = fixed;
  }

  pair get_origin(picture pic = currentpicture)
  {
    pair lo,hi;
    if (this.fixed) {
      lo = point(pic, SW);
      hi = point(pic, NE);
    }
    else {
      lo = truepoint(pic, SW);
      hi = truepoint(pic, NE);
    }
    return (this.origin.x*(hi.x-lo.x) + lo.x, this.origin.y*(hi.y-lo.y) + lo.y);
  }

  // draw invisible line on page to account for panel space
  void setframe(picture dest, picture pic, transform t, pair pos)
  {
    path p = t*(point(pic, SW)--point(pic, NE));
    p = shift(pos) * scale(1/dest.xunitsize, 1/dest.yunitsize) * p;
    draw(dest, p, invisible);
  }

  // setup panel
  void setpanel(real x, real y, pair origin)
  {
    this.haslimits = false;
    this.position = (x, y);
    this.origin = origin;
    if (currentpicture == pages.page || !currentpicture.empty())
      currentpicture = new picture;
  }

  void pushpanel()
  {
    // adds panel if exists
    if (currentpicture != pages.page && !currentpicture.empty()) {
      // set picture size
      if (this.fixed) size(this.size.x, this.size.y, point(SW), point(NE));
      else plain_size(this.size.x, this.size.y, this.aspect);

      // add picture to current page
      transform t = currentpicture.calculateTransform() * shift(-this.get_origin(currentpicture));
      this.setframe(pages.page, currentpicture, t, this.position);
      add(pages.page, currentpicture.fit(t), this.position);
    }
  }

  // creates new panel (push the old one to page)
  void newpanel(real x, real y, pair origin)
  {
    pushpanel();
    // setup fresh panel
    this.setpanel(x, y, origin);
    this.size(currentpicture, pages.size.x, pages.size.y, false, false, true);
  }
};
private Panel currentpanel;
// }}}2
// - user interface {{{2
// set limits of plot
void graph_limits(picture, pair, pair, bool) = limits;
void limits(picture, pair, pair, bool) = null;
void limits(picture pic = currentpicture, pair min = (-inf, -inf), pair max = (inf, inf), bool3 crop = default)
{
  if (currentpicture.empty() || currentpicture == pages.page || currentpanel.haslimits) return;

  // get automatic limits
  pair picmin = point(pic, SW);
  pair picmax = point(pic, NE);

  // fix automatic limits using graph scale
  scaleT xscale = pic.scale.x.scale;
  scaleT yscale = pic.scale.y.scale;
  picmin = (xscale.Tinv(picmin.x), yscale.Tinv(picmin.y));
  picmax = (xscale.Tinv(picmax.x), yscale.Tinv(picmax.y));

  // if user limits are invalid, overwrite by automatic limits
  min = (finite(min.x) ? min.x : picmin.x, finite(min.y) ? min.y : picmin.y);
  max = (finite(max.x) ? max.x : picmax.x, finite(max.y) ? max.y : picmax.y);

  // crop if forced by user
  if (crop == true)
    graph_limits(pic, min, max, crop);

  // scale back to picture coordinates before adjusting limits
  min = (xscale.T(min.x), yscale.T(min.y));
  max = (xscale.T(max.x), yscale.T(max.y));

  // center (0,0)
  if (currentpanel.center) {
    max = (max(abs(min.x), abs(max.x)), max(abs(min.y), abs(max.y)));
    min = -max;
  }

  // fix aspect
  if (currentpanel.aspect) {
    real ratio = currentpanel.size.y / currentpanel.size.x;
    if (ratio < (max-min).y / (max-min).x) {
      real meanx = 0.5(min.x + max.x);
      min = (meanx - 0.5(max.y - min.y)/ratio, min.y);
      max = (meanx + 0.5(max.y - min.y)/ratio, max.y);
    }
    else {
      real meany = 0.5(min.y + max.y);
      min = (min.x, meany - 0.5(max.x - min.x)*ratio);
      max = (max.x, meany + 0.5(max.x - min.x)*ratio);
    }
  }

  // back to graph scale
  min = (xscale.Tinv(min.x), yscale.Tinv(min.y));
  max = (xscale.Tinv(max.x), yscale.Tinv(max.y));

  // finally set limits
  graph_limits(pic, min, max, (crop == default) ? true : false);
  currentpanel.haslimits = true;
}

// new panel
void newpanel(real x = 0, real y = 0, pair origin = currentpanel.origin)
{
  limits();
  currentpanel.newpanel(x,-y,origin);
}

// new page function
newpage = new void(picture pic = finalpicture) {
  newpanel();
  pages.newpage(pic);
};

// edit page
void editpage()
{
  newpanel();
  currentpicture = pages.page;
}

// get size of grid
pair gridsize() { return pages.size; }

// set size of the plots
void gridsize(real x, real y)
{
  pages.gridsize(x,y);
  currentpanel.size(currentpicture, x, y, false, false, true);
}
void size(picture pic = currentpicture, real x = pages.size.x, real y = pages.size.y, bool keepAspect, bool center, bool fixed = true)
{
  currentpanel.size(pic, x, y, keepAspect, center, fixed);
}
void size(picture pic = currentpicture, real x, real y = x, bool keepAspect = false)
{
  currentpanel.size(pic, x, y, keepAspect, false, true);
}
void scalesize(picture pic = currentpicture, real x = 1, real y = 1, bool keepAspect = false, bool center = false, bool fixed = true)
{
  currentpanel.size(pic, x*pages.size.x, y*pages.size.y, keepAspect, center, fixed);
}
// }}}2
// - shipout {{{2
exitfunction = new void()
{
  // finish things up
  newpage();
  // shipout final picture
  currentpicture = finalpicture;
  if (needshipout()) shipout();
};
atexit(exitfunction);
// }}}2
// }}}1
// {{{1 Graph hacking #######################################################
// - graph coordinates {{{2
// transform user-coordinates to graph-coordinates
pair[] Scale(picture pic = currentpicture, pair[] z)
{
  for (int i = 0; i < z.length; ++i)
    z[i] = Scale(pic, z[i]);
  return z;
}

//// overwrite label to draw using graph-coordinates
//void plain_label(picture, Label, pair, align, pen, filltype) = label;
//void label(picture pic = currentpicture, Label L, pair position, align align = NoAlign, pen p = currentpen, filltype filltype = NoFill)
//{
//  plain_label(pic, L, Scale(pic,position), align, p, filltype);
//}

// overwrite dot to draw using graph-coordinates
void plain_dot(picture, pair, pen, filltype) = dot;
void dot(picture pic = currentpicture, pair z, pen p = currentpen, filltype filltype = Fill)
{
  plain_dot(pic, Scale(pic,z), p, filltype);
}

void plain_dot(picture, Label, pair, align, string, pen, filltype) = dot;
void dot(picture pic = currentpicture, Label L, pair z, align align = NoAlign, string format = defaultformat, pen p = currentpen, filltype filltype = Fill)
{
  plain_dot(pic, L, Scale(pic,z), align, format, p, filltype);
}

void plain_dot(picture, Label[], pair[], align, string, pen, filltype) = dot;
void dot(picture pic = currentpicture, Label[] L = new Label[], pair[] z, align align = NoAlign, string format = defaultformat, pen p = currentpen, filltype filltype = Fill)
{
  plain_dot(pic, L, Scale(pic,z), align, format, p, filltype);
}

// easily draw shaded areas on plots
void shade(picture pic = currentpicture, pair min, pair max, pen p = currentpen)
{
  fill(pic, box(Scale(pic, min), Scale(pic, max)), p);
}

void xshade(picture pic = currentpicture, real xmin, real xmax, pen p = currentpen)
{
  real ymin = pic.scale.y.scale.Tinv(point(pic,S).y);
  real ymax = pic.scale.y.scale.Tinv(point(pic,N).y);
  shade(pic, (xmin, ymin), (xmax, ymax), p);
}

void yshade(picture pic = currentpicture, real ymin, real ymax, pen p = currentpen)
{
  real xmin = pic.scale.x.scale.Tinv(point(pic,W).x);
  real xmax = pic.scale.x.scale.Tinv(point(pic,E).x);
  shade(pic, (xmin, ymin), (xmax, ymax), p);
}
// }}}2
// - axes {{{2
// overwrite xaxis to change some defaults
void plain_xaxis(picture, Label, axis, real, real, pen, ticks, arrowbar, margin, bool) = xaxis;
xaxis = new void (picture pic=currentpicture, Label L="", axis axis=BottomTop,
  real xmin=-infinity, real xmax=infinity, pen p=currentpen,
  ticks ticks=LeftTicks(Label(L.s=="%" ? invisible : p)),
  arrowbar arrow=None, margin margin=NoMargin, bool above=true)
{
  limits();
  plain_xaxis(pic,L.s=="%" ? "" : L,axis,xmin,xmax,p,ticks,arrow,margin,above);
};

// overwrite yaxis to change some defaults
void plain_yaxis(picture, Label, axis, real, real, pen, ticks, arrowbar, margin, bool, bool) = yaxis;
yaxis = new void (picture pic=currentpicture, Label L="", axis axis=LeftRight,
  real ymin=-infinity, real ymax=infinity, pen p=currentpen,
  ticks ticks=RightTicks(Label(L.s=="%" ? invisible : p)),
  arrowbar arrow=None, margin margin=NoMargin, bool above=true, bool autorotate = true)
{
  limits();
  plain_yaxis(pic,L.s=="%" ? "" : L,axis,ymin,ymax,p,ticks,arrow,margin,above,autorotate);
};
// }}}2
// - palette sidebar {{{2
void palette(picture pic=pages.page, Label L="", bounds bounds, real width = 4mm,
  real gap=1mm, axis axis=Right, pen[] palette=currentgradient, pen p=currentpen,
  paletteticks ticks=PaletteTicks, bool copy=true, bool antialias=false)
{
  picture curpic = currentpicture;
  currentpicture = new picture;
  currentpicture.scale.z.scale = curpic.scale.z.scale;

  Panel palettepanel;
  palettepanel.setpanel(currentpanel.position.x, currentpanel.position.y, currentpanel.origin);
  palettepanel.size(currentpanel.size.x, currentpanel.size.y, currentpanel.aspect, currentpanel.center, currentpanel.fixed);
  palettepanel.haslimits = true;

  if (axis == Left) {
    currentpanel.size -= (width+gap, 0);
    palettepanel.size(width, currentpanel.size.y, false, false, true);
    currentpanel.position += ((1-currentpanel.origin.x)*(width+gap)/pic.xunitsize, 0);
    palettepanel.position -= ((currentpanel.origin.x)*(currentpanel.size.x+gap)/pic.xunitsize, 0);
  }
  else if (axis == Bottom) {
    currentpanel.size -= (0, width+gap);
    palettepanel.size(currentpanel.size.x, width, false, false, true);
    currentpanel.position += (0, (1-currentpanel.origin.y)*(width+gap)/pic.yunitsize);
    palettepanel.position -= (0, (currentpanel.origin.y)*(currentpanel.size.y+gap)/pic.yunitsize);
  }
  else if (axis == Right) {
    currentpanel.size -= (width+gap, 0);
    palettepanel.size(width, currentpanel.size.y, false, false, true);
    currentpanel.position -= ((currentpanel.origin.x)*(width+gap)/pic.xunitsize, 0);
    palettepanel.position += ((1-currentpanel.origin.x)*(currentpanel.size.x+gap)/pic.xunitsize, 0);
  }
  else if (axis == Top) {
    currentpanel.size -= (0, width+gap);
    palettepanel.size(currentpanel.size.x, width, false, false, true);
    currentpanel.position -= (0, (currentpanel.origin.y)*(width+gap)/pic.yunitsize);
    palettepanel.position += (0, (1-currentpanel.origin.y)*(currentpanel.size.y+gap)/pic.yunitsize);
  }

  // draw and add palette
  palette(currentpicture, L, bounds, (0,0), (1,1), axis, palette, p, ticks, copy, antialias);
  palettepanel.pushpanel();
  currentpicture = curpic;
}
// }}}2
trailingzero = ""; // make trailingzero default formatting
// }}}1
