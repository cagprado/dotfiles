// Asymptote module:
// Standardize generating figures (plots) with asymptote
// Imports «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««1
import graph;
import graph3;
import palette;
import stats;
import contour;

// LaTeX configuration «««««««««««««««««««««««««««««««««««««««««««««««««««««1
// Redefine font size commands
restricted pen tiny         = fontsize( 6.00,  7.00);
restricted pen scriptsize   = fontsize( 8.00,  9.50);
restricted pen footnotesize = fontsize( 9.00, 11.00);
restricted pen small        = fontsize(10.00, 12.00);
restricted pen normalsize   = fontsize(10.95, 13.60);
restricted pen large        = fontsize(12.00, 14.50);
restricted pen Large        = fontsize(14.40, 18.00);
restricted pen LARGE        = fontsize(17.28, 22.00);
restricted pen huge         = fontsize(20.74, 25.00);
restricted pen Huge         = fontsize(24.88, 30.00);
defaultpen(normalsize);

// Write preamble
if (!settings.inlinetex) {
  private bool localpackage(string name) {
    if (error(input("../tex/" + name + ".sty", false)))
      return false;
    usepackage("../tex/" + name);
    return true;
  }

  private string TeXFontSize(pen p, string s) {
    static string TeX = "\renewcommand\%s{\fontsize{%f}{%f}\selectfont}";
    return format(format(replace(TeX, "%s", s), fontsize(p)), lineskip(p));
  }

  if (localpackage("settings"))
    localpackage("definitions");
  else {
    usepackage("amsmath");
    usepackage("siunitx");
  }

  texpreamble(""
    + TeXFontSize(tiny,         "tiny")
    + TeXFontSize(scriptsize,   "scriptsize")
    + TeXFontSize(footnotesize, "footnotesize")
    + TeXFontSize(small,        "small")
    + TeXFontSize(normalsize,   "normalsize")
    + TeXFontSize(large,        "large")
    + TeXFontSize(Large,        "Large")
    + TeXFontSize(LARGE,        "LARGE")
    + TeXFontSize(huge,         "huge")
    + TeXFontSize(Huge,         "Huge")
  );
}

// Pen definitions «««««««««««««««««««««««««««««««««««««««««««««««««««««««««1
//   · Plain scaling «««««««««««««««««««««««««««««««««««««««««««««««««««««««2
// setup scaling factors of several elements
dotfactor=5;
arrowfactor=10;
arcarrowfactor=0.5*arrowfactor;
barfactor=0.7*arrowfactor;
//tildemarksizefactor=5;
//stickmarkspacefactor=4;
//stickmarksizefactor=10;
//circlemarkradiusfactor=stickmarksizefactor/2;
//barmarksizefactor=stickmarksizefactor;
//crossmarksizefactor=5;
//markanglespacefactor=4;
//markangleradiusfactor=8;

//   · Line Styles «««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
// force 'dot' to use roundcap since we will use another style as default
private void plain_dot(frame, pair, pen, filltype) = dot;
dot = new void (frame f, pair z, pen p=currentpen, filltype ft=Fill) {
  plain_dot(f, z, p+roundcap, ft);
};

// shortcut wrapper for the actual linetype function
private pen linetype(bool scale=false ...real[] a) {
  return linecap(scale ? 1 : 0) + linetype(a, 0, scale, true);
}

// define line styles
solid           = linetype(false);           // ───────────────
dashed          = linetype(5,1);             // ─── ─── ─── ───
longdashed      = linetype(10,1);            // ──────   ──────
dashdotted      = linetype(5,1,1,1);         // ────── · ──────
pen dash2dotted = linetype(5,1,1,1,1,1);     // ───── · · ─────
pen dash3dotted = linetype(5,1,1,1,1,1,1,1); // ──── · · · ────
dotted          = linetype(true, 0,1.5);     // ···············
Dotted          = linetype(true, 0,4.0);     // · · · · · · · ·
longdashdotted  = nullpen;
defaultpen(1+solid);

private typedef pen lstyle();
pen operator cast(lstyle l) { return l(); }
restricted lstyle[] lstyle = {
  new pen() { return solid; },
  new pen() { return dashed; },
  new pen() { return longdashed; },
  new pen() { return dashdotted; },
  new pen() { return dash2dotted; },
  new pen() { return dash3dotted; },
  new pen() { return dotted; },
  new pen() { return Dotted; }
};
lstyle.cyclic = true;

//   · Markers «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
restricted typedef marker mstyle(real s = dotfactor, pen p = currentpen, pen f = white);
restricted marker operator cast(mstyle mstyle) { return mstyle(); }

// append marker 'b' on top of 'a'
restricted marker operator+(marker a, marker b) {
  marker m = new marker;
  add(m.f, a.f);
  add(m.f, b.f);
  m.above = b.above;
  m.markroutine = b.markroutine;
  return m;
}

// regular star polygon denoted by its Schläfli symbol {n/m}
path star(int n, int m = 2) {
  path p1 = polygon(n);
  path p2 = scale(cos(pi*m/n)/cos(pi*(m-1)/n))*rotate(180/n)*polygon(n);
  guide g;
  for (int i = 0; i < n; ++i)
    g = g--point(p1,i)--point(p2,i);
  return g--cycle;
}

// filled scaled marker from path
private mstyle filled_marker(real r, path[] m) {
  return new marker(real s=0.5dotfactor, pen p=currentpen, pen f=white) {
    return marker(scale(r*s)*m, Fill(p));
  };
}

// outlined scaled marker from path
private mstyle outlined_marker(real r, path[] m) {
  return new marker(real s=0.5dotfactor, pen p=currentpen, pen f=white) {
    return marker(scale(r*s)*m, FillDraw(f, p));
  };
}

// define default markers
restricted mstyle mstyle[] = {
  // ● ■ ▲ ★ × + ✳ , then open version (in reverse order)
  filled_marker(1, unitcircle),
  filled_marker(1.2, polygon(4)),
  filled_marker(1.2, polygon(3)),
  filled_marker(1.2, star(5)),
  outlined_marker(1.2, cross(4)),
  outlined_marker(1.2, rotate(45)*cross(4)),
  outlined_marker(1.2, cross(6)),

  outlined_marker(1.2, cross(6, false, 0.4)),
  outlined_marker(1.2, rotate(45)*cross(4, false, 0.4)),
  outlined_marker(1.2, cross(4, false, 0.4)),
  outlined_marker(1.2, star(5)),
  outlined_marker(1.2, polygon(3)),
  outlined_marker(1.2, polygon(4)),
  outlined_marker(1, unitcircle),
};
mstyle.cyclic = true;

// define errorbar marker for legends
restricted mstyle merror = outlined_marker(
  1, (-2, -1) -- (-2, 1) ^^ (-2, 0) -- (2, 0) ^^ (2, -1) -- (2, 1)
);

//   · Color palettes ««««««««««««««««««««««««««««««««««««««««««««««««««««««2
// Get only color property from a pen
pen get_color(pen p=defaultpen) {
  if (invisible(p))
    return invisible;

  real[] c = colors(cmyk(p));
  return cmyk(c[0], c[1], c[2], c[3]);
}

// Define colors (don't override black and white pens, it'll break things)
pen Black = rgb("4d4d4d");
red       = rgb("c82829");
blue      = rgb("4271ae");
green     = rgb("718c00");
orange    = rgb("f5871f");
purple    = rgb("8959a8");
cyan      = rgb("3e999f");
yellow    = rgb("eab700");
gray      = rgb("8e908c");
defaultpen(Black);

// Define color array
private typedef pen color();
pen operator cast(color c) { return c(); }
restricted color[] color = {
  new pen() { return get_color(); },
  new pen() { return red; },
  new pen() { return blue; },
  new pen() { return green; },
  new pen() { return orange; },
  new pen() { return purple; },
  new pen() { return cyan; },
  new pen() { return yellow; },
  new pen() { return gray; }
};
color.cyclic = true;

//   · Color gradients «««««««««««««««««««««««««««««««««««««««««««««««««««««2
//     - CIE L*a*b «««««««««««««««««««««««««««««««««««««««««««««««««««««««««3
// Conversion from rgb to CIE L*a*b is device dependent so this is probably
// not really correct.  This conversion is based in Chroma.js code:
// https://github.com/gka/chroma.js
private struct lab {
  // CIE L*a*b colorspace
  restricted real l, a, b, o;
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
      return 12.92r;
    else
      return 1.055r^(5/12) - 0.055;
  }

  private real xyz_lab(real x) {
    if (x > 0.008856)
      return x^(1/3);
    else
      return 7.787037x + 4/29;
  }

  private real lab_xyz(real x) {
    if (x > 0.206893034)
      return x^3;
    else
      return (x - 4/29) / 7.787037;
  }

  private real[] rgb2xyz(real[] rgb) {
    real r = rgb_xyz(rgb[0]);
    real g = rgb_xyz(rgb[1]);
    real b = rgb_xyz(rgb[2]);
    real x = xyz_lab((0.4124564r + 0.3575761g + 0.1804375b)/X);
    real y = xyz_lab((0.2126729r + 0.7151522g + 0.0721750b)/Y);
    real z = xyz_lab((0.0193339r + 0.1191920g + 0.9503041b)/Z);
    return new real[] {x,y,z};
  }

  void operator init(real l, real a, real b, real o = 1) {
    this.l = l;
    this.a = a;
    this.b = b;
    this.o = o;
  }

  void operator init(pen p) {
    real[] xyz = rgb2xyz(colors(rgb(p)));
    real x = xyz[0];
    real y = xyz[1];
    real z = xyz[2];
    this.l = 116y - 16;
    this.a = 500(x - y);
    this.b = 200(y - z);
    this.o = opacity(p);
  }

  pen rgb() {
    real y = (this.l + 16) / 116;
    real x = y + this.a / 500;
    real z = y - this.b / 200;
    x = lab_xyz(x) * X;
    y = lab_xyz(y) * Y;
    z = lab_xyz(z) * Z;
    real r = max(0, min(1, xyz_rgb( 3.2404542x - 1.5371385y - 0.4985314z)));
    real g = max(0, min(1, xyz_rgb(-0.9692660x + 1.8760108y + 0.0415560z)));
    real b = max(0, min(1, xyz_rgb( 0.0556434x - 0.2040259y + 1.0572252z)));
    return rgb(r, g, b) + opacity(o);
  }
}

// Convert CIE L*a*b to rgb space
pen operator cast(lab lab) {
  return lab.rgb();
}

// Convert pen to CIE L*a*b space
lab operator cast(pen p) {
  return lab(p);
}

// Convert array of pens to CIE L*a*b space
lab[] operator cast(pen[] pens) {
  lab[] lab;
  for (pen p : pens)
    lab.push(lab(p));
  return lab;
}

// Get array of values for CIE L*a*b colorspace
real[] colors(lab c) {
  return new real[] { c.l, c.a, c.b };
}
//     - Interpolator ««««««««««««««««««««««««««««««««««««««««««««««««««««««3
private typedef lab interpolator(real);
private interpolator bezier_interpolator(lab[] colors) {
  interpolator I;
  if (colors.length == 2) { // linear
    I = new lab (real t) {
      real l,a,b,o;
      l = colors[0].l + t*(colors[1].l - colors[0].l);
      a = colors[0].a + t*(colors[1].a - colors[0].a);
      b = colors[0].b + t*(colors[1].b - colors[0].b);
      o = colors[0].o + t*(colors[1].o - colors[0].o);
      return lab(l,a,b,o);
    };
  }
  else if (colors.length == 3) { // quadratic
    I = new lab (real t) {
      real l,a,b,o;
      l = (1-t)^2 * colors[0].l + 2*(1-t)*t * colors[1].l + t^2 * colors[2].l;
      a = (1-t)^2 * colors[0].a + 2*(1-t)*t * colors[1].a + t^2 * colors[2].a;
      b = (1-t)^2 * colors[0].b + 2*(1-t)*t * colors[1].b + t^2 * colors[2].b;
      o = (1-t)^2 * colors[0].o + 2*(1-t)*t * colors[1].o + t^2 * colors[2].o;
      return lab(l,a,b,o);
    };
  }
  else if (colors.length == 4) { // cubic
    I = new lab (real t) {
      real l,a,b,o;
      l = (1-t)^3 * colors[0].l + 3*(1-t)^2*t * colors[1].l + 3*(1-t)*t^2 * colors[2].l + t^3 * colors[3].l;
      a = (1-t)^3 * colors[0].a + 3*(1-t)^2*t * colors[1].a + 3*(1-t)*t^2 * colors[2].a + t^3 * colors[3].a;
      b = (1-t)^3 * colors[0].b + 3*(1-t)^2*t * colors[1].b + 3*(1-t)*t^2 * colors[2].b + t^3 * colors[3].b;
      o = (1-t)^3 * colors[0].o + 3*(1-t)^2*t * colors[1].o + 3*(1-t)*t^2 * colors[2].o + t^3 * colors[3].o;
      return lab(l,a,b,o);
    };
  }
  else {
    interpolator I0 = bezier_interpolator(colors[0:colors.length#2+1]);
    interpolator I1 = bezier_interpolator(colors[colors.length#2:]);
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
private correction mapscale(interpolator I) {
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

//     - Palette generators ««««««««««««««««««««««««««««««««««««««««««««««««3
typedef pen[] Palette(int _=null, pen _=nullpen, pen _=nullpen);
pen[] operator cast(Palette p) {return p();}
private Palette base_palette;
private real[] base_ratios;

private Palette Palette(pen[] g(int _=0)) {
  pen p[], underflow, overflow;
  pen[] P(int n=0, pen u=nullpen, pen o=nullpen) {
    if (n < 0) {
      n = p.length;
      u = underflow;
      o = overflow;
      if (base_ratios.length > 0)
        p = g(n);
    }

    // generate palette if necessary
    underflow = u;
    overflow = o;
    p = n == 0 ? g() : (n != p.length) ? g(n) : p;
    base_palette = P;

    // add under/over flow and return copy of array
    return concat(concat(
      u==nullpen ? new pen[] : new pen[] {u}, p),
      o==nullpen ? new pen[] : new pen[] {o}
    );
  }

  return P;
}

Palette reset(Palette palette) {
  palette(0, nullpen, nullpen);
  return palette;
}

// Returns a palette interpolation in CIE L*a*b space given pens
Palette LabGradient(bool correct=true ... pen[] p) {
  lab[] lab = sequence(new lab(int i) { return p[i]; }, p.length);
  interpolator I = bezier_interpolator(lab);
  correction C = correct ? mapscale(I) : identity;

  return Palette(new pen[] (int n=500) {
    return sequence(new pen(int i) { return I(C(i/max(1,n-1))); }, n);
  });
}

// Returns a palette interpolation in CIE L*a*b space given strings
Palette LabGradient(bool correct=true ... string[] p) {
  pen[] pen = sequence(new pen(int i) { return rgb(p[i]); }, p.length);
  return LabGradient(correct ... pen);
}

// Returns a monochromatic palette
Palette Monochrome(bool correct=true, pen p) {
  return LabGradient(correct, gray(0), p, 2p, gray(1));
}

// Returns a concatenation of several palettes given pens
Palette LabGradient(bool correct=true, pen[][] p) {
  return Palette(new pen[](int n=500) {
    pen[] palette;
    int m = n;
    for (int i = 0; i < p.length-1; ++i) {
      real r = base_ratios.length > i ? base_ratios[i] : 1/p[i:].length;
      int n1 = max(0, min(n, 1 + floor(r*m)));
      int n2 = max(0, min(n, 1 + floor((1-r+realEpsilon)*m)));
      palette.append((n1 == 1 && n2 == m
        ? p[i+1][:1]
        : LabGradient(correct ... p[i])(n1)[:m-n2+1]
      )[palette.length>0 ? 1 : 0 :]);
      m = n2;
    }
    palette.append(LabGradient(correct ... p[p.length-1])(max(1,m))[1:]);
    return palette;
  });
}

// Returns a concatenation of several palettes given strings
Palette LabGradient(bool correct=true, string[][] p) {
  pen[][] pen = sequence(new pen[](int i) {
    return sequence(new pen(int j) {
      return rgb(p[i][j]);
    }, p[i].length);
  }, p.length);
  return LabGradient(correct, pen);
}

//     - Range adjustment ««««««««««««««««««««««««««««««««««««««««««««««««««3
// When adjusting palette for image plots, consider splitting ratios
pen[] palette_adjust(picture, real, real, real, real, pen[]) = adjust;
adjust = new pen[](picture pic, real min, real max, real rmin, real rmax,
                   pen[] palette) {
  palette = palette_adjust(pic, min, max, rmin, rmax, base_ratios.length > 0
                           ? base_palette(-1) : palette);
  base_ratios.delete();
  return palette;
};

// Define Split and Divergent types of Range for image plots
range Split(real[] splits, bool automin=false, real min=-infinity,
            bool automax=false, real max=infinity) {
  range range = Range(automin, min, automax, max);
  return new bounds(picture pic, real dmin, real dmax) {
    bounds bounds = range(pic, dmin, dmax);

    real m = pic.scale.z.T(bounds.min);
    real M = pic.scale.z.T(bounds.max);
    for (real s : splits) {
      base_ratios.push((pic.scale.z.T(s)-m)/(M-m));
      m = s;
    }

    return bounds;
  };
}

range Divergent(real center=0, bool automin=false, real min=-infinity,
                bool automax=false, real max=infinity) {
  return Split(new real[] {center}, automin, min, automax, max);
}

range Divergent=Divergent();

//     - Default palettes ««««««««««««««««««««««««««««««««««««««««««««««««««3
// Set default gradient palettes to be used
Palette[] gradient = {
  // matplotlib viridis based
  LabGradient("440154", "472c7b", "3a528b", "2c728e",
              "20918c", "28af80", "5ec962", "addd30"),
  // matplotlib cividis based
  LabGradient("00224e", "1a386f", "434e6c", "61656f",
              "7d7c78", "9b9476", "bcae6c", "deca57"),
  LabGradient("000000", "ff0000", "ffdd00", "ffffff"),
  // matplotlib BrBG based
  LabGradient(new string[][] {
    {"543005", "8c510a", "bf812d", "dfc27d", "f6e8c3", "f5f5f5"},
    {"f5f5f5", "c7eae5", "80cdc1", "35978f", "01665e", "003c30"}
  }),
  // matplotlib PRGn based
  LabGradient(new string[][] {
    {"40004b", "762a83", "9970ab", "c2a5cf", "e7d4e8", "f7f7f7"},
    {"f7f7f7", "d9f0d3", "a6dba0", "5aae61", "1b7837", "00441b"}
  }),
  Palette(Rainbow),
  Palette(Grayscale)
};
Palette currentgradient = gradient[0];

// Helper function «««««««««««««««««««««««««««««««««««««««««««««««««««««««««1
//   · Arrays ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
// Returns (n, m) matrix from array
real[][] balance(real data[], int n, int m) {
  return sequence(new real[](int i) {return sequence(new real(int j) {
    return data[i*m+j];
  }, m);}, n);
}

// Column/Line "slices" returns matrix[*][col]
string[] column(string matrix[][], int col) {
  return sequence(new string(int i) {return matrix[i][col];}, matrix.length);
}

real[] column(real matrix[][], int col) {
  return sequence(new real(int i) {return matrix[i][col];}, matrix.length);
}

real[] line(real matrix[][], int lin) {
  return sequence(new real(int i) {return matrix[lin][i];},
                  matrix.length > lin ? matrix[lin].length : 0);
}

// Some useful maps
bool3[] map(bool3 f(real), real[] x) {
  return sequence(new bool3(int i) {return f(x[i]);}, x.length);
}

// Returns an array of the midpoints between every pair in v
real[] midpoints(real v[]) {
  return 0.5 * (v[1:] + v[:v.length-1]);
}

// Shortcut for concatenation of array and value
real[] operator ..(real x, real v[]) {
  return concat(new real[] {x}, v);
}

real[] operator ..(real v[], real x) {
  return concat(v, new real[] {x});
}

// Arithmetic operators
real[][] operator+(real m[][], real x) {
  return map(new real[](real v[]) {return x+v;}, m);
}

real[][] operator/(real x, real m[][]) {
  return map(new real[](real v[]) {return x/v;}, m);
}

// Remove repetitions from ordered array
real[] unique(real v[], bool copy=true) {
  if (copy) v = copy(v);
  for (int i = v.length - 1; i > 0; --i)
    if (v[i] <= v[i-1])
      v.delete(i-1);
  return v;
}

//   · Math ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
real maxabs(real x, real y) {
  return max(abs(x), abs(y));
}

// restrict number to interval
int restrict(int a, int x, int b) {
  return max(a, min(x, b));
}

real restrict(real a, real x, real b) {
  return max(a, min(x, b));
}

// return angle considering picture aspect ratio
real realangle(picture pic=currentpicture, real angle) {
  bool unit = pic.xunitsize != 0 && pic.yunitsize != 0;
  bool size = pic.xsize != 0 && pic.ysize != 0;
  if (unit && (pic.keepAspect || !size))
    return atan(tan(angle) * pic.yunitsize / pic.xunitsize);
  else if (size && !pic.keepAspect)
    return atan(tan(angle) * pic.ysize / pic.xsize);
  return angle;
}

real realAngle(picture pic=currentpicture, real degrees) {
  return degrees(realangle(pic, radians(degrees)));
}

// make simple real functions also act on pairs
private typedef pair pfunc(pair);
pfunc operator cast(real f(real)) {
  return new pair(pair p) { return (f(p.x), f(p.y)); };
}

//   · Process «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
int shell(string commands, string pipe=">/dev/null 2>&1") {
  return system(new string[] {"sh", "-c", commands + pipe});
}

private string fileprocess(string command) {
  string fifo = format("asyprocess%d", rand());
  while (shell("mkfifo " + fifo) != 0)
    fifo = format("asyprocess%d", rand());
  shell(command, '>"' + fifo + '" 2>&1 && rm "' + fifo + '" &!');
  return fifo;
}

file process(string command, string comment="#", string mode="") {
  return input(fileprocess(command), comment, mode);
}

//   · Strings «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
string char(string s, int i) {
  return substr(s, i, i+1);
}

// Graph tuning ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««1
//   · Settings ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
ngraph = 300;
trailingzero = ""; // make trailingzero the default format
legendhskip = 1.2;
legendvskip = 1.2;
legendmargin = 0.2 fontsize(defaultpen);
legendlinelength = 1.2 fontsize(defaultpen);

//   · Scaling and coordinates «««««««««««««««««««««««««««««««««««««««««««««2
// transform graph-coordinates to user-coordinates
pair Unscale(picture pic=currentpicture, pair z) {
  return (pic.scale.x.Tinv(z.x), pic.scale.y.Tinv(z.y));
}

// transform user-coordinates to graph-coordinates
pair[] Scale(picture pic=currentpicture, pair[] z) {
  return map(new pair(pair x) { return Scale(pic, x); }, z);
}

guide Scale(picture pic=currentpicture, guide g) {
  guide gg = Scale(pic, point(g, 0));
  for (int i : sequence(length(g)))
    gg = gg ..  controls Scale(pic, postcontrol(g,i))
         and Scale(pic, precontrol(g,i+1)) .. Scale(pic, point(g,i+1));
  return gg;
}

guide[] Scale(picture pic=currentpicture, guide[] g) {
  return sequence(new guide(int i) { return Scale(g[i]); }, g.length);
}

guide[][] Scale(picture pic=currentpicture, guide[][] g) {
  return sequence(new guide[](int i) { return Scale(g[i]); }, g.length);
}

// overwrite label to draw using graph-coordinates
void label(picture pic=currentpicture, Label L, pair position,
           align align=NoAlign, pen p=currentpen,
           filltype filltype=NoFill) {
  plain.label(pic, L, Scale(pic,position), align, p, filltype);
}

// overwrite dot to draw using graph-coordinates
void dot(picture pic=currentpicture, pair z, pen p=currentpen,
         filltype filltype=Fill) {
  plain.dot(pic, Scale(pic,z), p, filltype);
}

void dot(picture pic=currentpicture, Label L, pair z,
         align align=NoAlign, string format=defaultformat,
         pen p=currentpen, filltype filltype=Fill) {
  plain.dot(pic, L, Scale(pic,z), align, format, p, filltype);
}

void dot(picture pic=currentpicture, Label[] L=new Label[], pair[] z,
         align align=NoAlign, string format=defaultformat,
         pen p = currentpen, filltype filltype = Fill) {
  plain.dot(pic, L, Scale(pic,z), align, format, p, filltype);
}

// overwrite point and truepoint functions to work with graph-coordinates
pair point(picture pic=currentpicture, pair dir, bool user=true) {
    pair z = plain.point(pic, dir, user);
    return Unscale(z);
}

pair truepoint(picture pic=currentpicture, pair dir, bool user=true) {
    pair z = plain.truepoint(pic, dir, user);
    return Unscale(z);
}

// define a safe version o Log scale that avoids out-of-domain problem
private scaleT SafeLog(int logMin) {
  --logMin;
  return scaleT(new real(real x) {return x>0 ? log10(x) : logMin;},
                pow10, logarithmic=true);
}

scaleT Log(bool, bool) = null;
scaleT Log(int logMin=ceil(log10(realMax)),
           bool automin=false, bool automax=automin) {
  graph.Log = SafeLog(logMin);
  return graph.Log(automin, automax);
}

scaleT BrokenLog(real, real, bool, bool) = null;
scaleT BrokenLog(real a, real b, int logMin=ceil(log10(realMax)),
                 bool automin=false, bool automax=automin) {
  graph.Log = SafeLog(logMin);
  return graph.BrokenLog(a, b, automin, automax);
}

scaleT Log = Log();
scaleT Logarithmic = Log;

// account for scaling in x and y and distort the matrix appropriately
bounds image(picture pic=currentpicture, real[][] f, range range=Automatic,
             pair initial, pair final, pen[] p,
             bool tr=(initial.x < final.x && initial.y < final.y),
             bool copy=true, bool aalias=false) {
  if (pic.scale.x.scale.T==identity && pic.scale.x.postscale.T==identity &&
      pic.scale.y.scale.T==identity && pic.scale.y.postscale.T==identity)
    return palette.image(pic, f, range, initial, final, p, tr, copy, aalias);

  static int index(int n, real x, real m, real M) {
    return floor(max(0, min(n-1, n * (x-m)/(M-m))));
  }

  return image(pic, new real(real x, real y) {
    int i = index(f.length, x, initial.x, final.x);
    int j = index(f[i].length, y, initial.y, final.y);
    return f[i][j];
  }, range, initial, final, p, aalias);
}

// make contour guide[][] work with scales other than identity
private void draw_orig(picture, Label[], guide[][], pen[]) = contour.draw;
contour.draw = new void(picture pic=currentpicture, Label[] L=new Label[],
                        guide[][] g, pen[] p) {
  bool scale = pic.scale.x.scale.T != identity
            || pic.scale.y.scale.T != identity
            || pic.scale.x.postscale.T != identity
            || pic.scale.y.postscale.T != identity;
  draw_orig(pic, L, scale ? Scale(pic, g) : g, p);
};

//   · Limits ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
void limits(picture, pair, pair, bool) = null;
void limits(picture pic=currentpicture, pair min=(-inf, -inf),
            pair max=(inf, inf), bool center=false, bool3 crop=default) {
  if (!pic.empty3() || pic.empty2() || pic.fixed
      || pic.xsize == 0 || pic.ysize == 0
      || pic.xunitsize != 0 || pic.yunitsize != 0)
    return;

  // get automatic limits
  graph.limits((-inf, -inf), (inf, inf));
  pair a = point(pic, NE);
  pair b = point(pic, SW);
  pair picmin = (min(a.x, b.x), min(a.y, b.y));
  pair picmax = (max(a.x, b.x), max(a.y, b.y));
  pair logMin = Unscale(pic, Scale(pic, (-inf, -inf)) + (1, 1));
  picmin = (logMin.x < picmax.x ? max(logMin.x, picmin.x) : picmin.x,
            logMin.y < picmax.y ? max(logMin.y, picmin.y) : picmin.y);
  pair picmid = 0.5*(picmin + picmax);

  // if user limits are infinite/invalid, overwrite by automatic limits
  pair umin = Unscale(pic, Scale(pic, min));
  pair umax = Unscale(pic, Scale(pic, max));
  min = (finite(min.x) && min.x==umin.x ? min.x : picmin.x,
         finite(min.y) && min.y==umin.y ? min.y : picmin.y);
  max = (finite(max.x) && max.x==umax.x ? max.x : picmax.x,
         finite(max.y) && max.y==umax.y ? max.y : picmax.y);

  // if user limits are empty (max == min) set as midpoint for crop
  if (min.x == max.x) {
    min = (picmid.x, min.y);
    max = (picmid.x, max.y);
  }
  if (min.y == max.y) {
    min = (min.x, picmid.y);
    max = (max.x, picmid.y);
  }

  // crop if forced by user
  if (crop == true)
    clip(pic, box(min, max));

  // scale to picture coordinates before adjusting center and aspect
  min = Scale(pic, min);
  max = Scale(pic, max);

  // center (0,0)
  if (center)
    min = -(max = (maxabs(min.x, max.x), maxabs(min.y, max.y)));

  // fix aspect
  if (pic.keepAspect) {
    real ratio = pic.ysize / pic.xsize;
    if (ratio*(max-min).x < (max-min).y) {
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

  // finally set limits
  graph.limits(pic, Unscale(min), Unscale(max), crop != false);

  // set picture size based on set graph limits
  if (pic.userSetx() && pic.userSety()) {
    // modification of fixedscaling(picture, pair, pair, pen, bool)
    pic.fixed = true;
    pair userm = pic.userMax2() - pic.userMin2();
    userm = (userm.x==0 ? 1 : abs(userm.x), userm.y==0 ? 1 : abs(userm.y));
    pic.fixedscaling = (0, 0, pic.xsize/userm.x, 0, 0, pic.ysize/userm.y);
  }
}

// Range is basically limits for the z coordinate in density plots
range Range(bool automin=false, real min=-infinity,
            bool automax=false, real max=infinity) {
  //range range = palette.Range(automin, min, automax, max);
  return new bounds(picture pic, real dmin, real dmax) {
    // if SafeLog, adjust dmin
    real logMin = pic.scale.z.Tinv(pic.scale.z.T(-inf)+1);
    dmin = logMin < dmax ? max(logMin, dmin) : dmin;

    // autoscale routine finds reasonable limits
    bounds mz=autoscale(pic.scale.z.T(dmin),
                        pic.scale.z.T(dmax),
                        pic.scale.z.scale);

    // If automin/max, use autoscale result, else
    //   if min/max is finite/valid, use specified value, else
    //   use minimum/maximum data value
    real f(bool auto, real mz, real dm, real m) {
      return auto
        ? pic.scale.z.Tinv(mz)
        : finite(m) && m==pic.scale.z.Tinv(pic.scale.z.T(m)) ? m : dm;
    }
    return bounds(f(automin,mz.min,dmin,min), f(automax,mz.max,dmax,max));
  };
}

Automatic = Range(true, true);
Full = Range();

//   · Axes ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
// overwrite xaxis to change some defaults
void xaxis(picture pic=currentpicture, Label L="", axis axis=BottomTop,
           real xmin=-infinity, real xmax=infinity, pen p=currentpen,
           ticks ticks=LeftTicks(Label(L.s=="%" ? invisible : p)),
           arrowbar arrow=None, margin margin=NoMargin, bool above=true) {
  limits();
  graph.xaxis(pic, L.s=="%" ? "" : L, axis, xmin, xmax, p, ticks, arrow,
              margin, above);
};

// overwrite yaxis to change some defaults
void yaxis(picture pic=currentpicture, Label L="", axis axis=LeftRight,
           real ymin=-infinity, real ymax=infinity, pen p=currentpen,
           ticks ticks=RightTicks(Label(L.s=="%" ? invisible : p)),
           arrowbar arrow=None, margin margin=NoMargin, bool above=true,
           bool autorotate = true) {
  limits();
  graph.yaxis(pic, L.s=="%" ? "" : L, axis, ymin, ymax, p, ticks, arrow,
              margin, above, autorotate);
};

// draw shaded areas on plots
void shade(picture pic=currentpicture, pair min, pair max, pen p=currentpen) {
  fill(pic, box(Scale(pic, min), Scale(pic, max)), p);
}

void xshade(picture pic=currentpicture, real x1, real x2, pen p=currentpen) {
  real y1 = point(pic,S).y;
  real y2 = point(pic,N).y;
  shade(pic, (x1, y1), (x2, y2), p);
}

void yshade(picture pic=currentpicture, real y1, real y2, pen p=currentpen) {
  real x1 = point(pic,W).x;
  real x2 = point(pic,E).x;
  shade(pic, (x1, y1), (x2, y2), p);
}

//   · Legend ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
// clear legend
void legend_delete(picture pic = currentpicture) {
  pic.legend.delete();
}

// add item to legend
void legend_push(picture pic=currentpicture, string label="",
                 pen plabel=invisible, marker mark=new marker,
                 bool above=true) {
  pic.legend.push(Legend(label, plabel, mark.f, above));
}

// define a new legenditem function left-aligned
private picture legenditemR(Legend, real) = legenditem;
private picture legenditemL(Legend legenditem, real linelength) {
  picture pic;
  pair z1=(0,0);
  pair z2=z1+(linelength,0);
  if(!legenditem.above && !empty(legenditem.mark))
    marknodes(pic,legenditem.mark,interp(z1,z2,0.5));
  if(linelength > 0)
    Draw(pic,z1--z2,legenditem.p);
  if(legenditem.above && !empty(legenditem.mark))
    marknodes(pic,legenditem.mark,interp(z1,z2,0.5));
  if(legenditem.plabel != invisible)
    label(pic,legenditem.label,z1,W,legenditem.plabel);
  else
    label(pic,legenditem.label,z1,W,currentpen);
  return pic;
}

// redefine legend to use invisible border by default
void legend(picture pic=currentpicture, int perline=1,
            real xmargin=legendmargin, real ymargin=xmargin,
            real linelength=legendlinelength, real hskip=legendhskip,
            real vskip=legendvskip, real maxwidth=perline == 0 ?
            legendmaxrelativewidth*size(pic).x : 0, real maxheight=0,
            bool hstretch=false, bool vstretch=false, pair position,
            pair align=0, pen plabel=currentpen+footnotesize,
            pen pborder=invisible, filltype filltype=NoFill) {
  // make text color always default despite the line color
  for (Legend item : pic.legend)
    item.plabel = plabel;

  // negative values of 'perline' aligns text to the left side of markers
  legenditem = (perline < 0) ? legenditemL : legenditemR;

  // add legend
  frame legend = legend(pic, abs(perline), xmargin, ymargin, linelength,
                        hskip, vskip, maxwidth, maxheight, hstretch,
                        vstretch, pborder);
  add(pic, legend, Scale(position), align, filltype);
}

//   · Error blocks ««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
void drawbox(picture pic, pair z, pair m, pair M, pair dd, pen p) {
  pic.add(new void(frame f, transform t) {
    picture pp;
    draw(pp, box(t*Scale(pic, z+m) - 0.5dd, t*Scale(pic, z+M) + 0.5dd), p);
    add(f, pp.fit());
  });
  draw(pic, Scale(pic, z+m) -- Scale(pic, z+M), nullpen);
}

void graph_errorbar(picture, pair, pair, pair, pen, real) = graph.errorbar;
void errorblock(picture pic, pair z, pair dp, pair dm, pen p=currentpen,
                real size=0) {
  size = size == 0 ? barsize(p) : size;
  real dmx = -abs(dm.x);
  real dmy = -abs(dm.y);
  real dpx = abs(dp.x);
  real dpy = abs(dp.y);
  if (dmx != dpx && dmy != dpy)
    drawbox(pic, z, (dmx, dmy), (dpx, dpy), 0, p);
  else if (dmx != dpx)
    drawbox(pic, z, (dmx, 0), (dpx, 0), (0, size), p);
  else if (dmy != dpy)
    drawbox(pic, z, (0, dmy), (0, dpy), (size, 0), p);
}

void errorblocks(picture pic=currentpicture, pair[] z, pair[] dp,
                 pair[] dm={}, bool[] cond={}, pen p=currentpen,
                 real size=0) {
  errorbar = errorblock;
  errorbars(pic, z, dp, dm, cond, p, size);
  errorbar = graph_errorbar;
}

void errorblocks(picture pic=currentpicture, real[] x, real[] y,
                 real[] dpx, real[] dpy, real[] dmx={}, real[] dmy={},
                 bool[] cond={}, pen p=currentpen, real size=0) {
  errorbar = errorblock;
  errorbars(pic, x, y, dpx, dpy, dmx, dmy, cond, p, size);
  errorbar = graph_errorbar;
}

void errorblocks(picture pic=currentpicture, real[] x, real[] y,
                 real[] dpy, bool[] cond={}, pen p=currentpen, real size=0) {
  errorblocks(pic,x,y,0*x,dpy,cond,p,size);
}

// Picture/pages management ««««««««««««««««««««««««««««««««««««««««««««««««1
//   · 3D pictures «««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
private void finish3d() {
  if (!currentpicture.empty3()) {
    picture pic;
    unitsize(pic, currentpicture.xsize, currentpicture.ysize);
    add(pic, currentpicture.fit(), (-0.5, 0.5));
    currentpicture = pic;
    layer();
  }
}

//   · Aspect ratio ««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
struct ratio {
  restricted pair ratio;

  // construct from two reals
  void operator init(real x, real y=1.0) {
    ratio = (x/y, 1);
  }

  // construct from pair
  void operator init(pair z) {
    operator init(z.x, z.y);
  }

  // copy contructor
  void operator init(ratio rhs) {
    ratio = (rhs.ratio.x, rhs.ratio.y);
  }

  // match y to s and scale x accordingly
  void scale(real s) {
    if (s < 0) ratio = I*conj(ratio);
    ratio *= abs(s)/ratio.y;
  }

  // reverse coordinates to represent height x width.
  void reverse() {
    ratio *= I;
  }

  // get the representation pair
  pair get() {
    return (ratio.x < 0) ? -I*ratio : ratio;
  }
}

pair operator cast(ratio r) {
  return r.get();
}

ratio operator *(real x, ratio r) {
  ratio r = ratio(r);
  r.scale(x);
  return r;
}

ratio operator /(real x, ratio r) {
  ratio r = ratio(r);
  r.reverse();
  r.scale(x);
  return r;
}

ratio operator -(ratio r) {
  return -1*r;
}

void size(picture pic=currentpicture, ratio r,
          bool keepAspect=pic.keepAspect) {
  pair ratio = r.get();
  size(pic, ratio.x, ratio.y, keepAspect);
}

ratio wide = ratio(16/9);
ratio tv = ratio(4/3);

//   · Grid ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
struct Grid {
  static picture pic;
  static transform[] grid;

  static void setup() {
    if (currentpicture.xsize == 0 || currentpicture.ysize == 0)
      abort("No size specified, can't define grid...");
    grid.push(scale(currentpicture.xsize, currentpicture.ysize));
    size(pic, currentpicture);
  }

  static void newgrid(real nx, real ny, pair sep) {
    if (grid.length == 0)
      setup();

    sep = inverse(shiftless(grid[-1])) * sep;
    transform g = scale((1+sep.x)/nx, (1+sep.y)/ny);
    grid.insert(0, inverse(g)*shift(sep));
    grid.push(grid[-1] * g);
  }

  static void newpanel(real x=0, real y=0, real sx=1, real sy=1,
                       bool keepAspect=false, transform t=identity) {
    grid.push(grid[-1] * shift(x, -y) * scale(sx-grid[0].x, sy-grid[0].y));
    pair size = shiftless(grid[-1]) * (1, 1);
    if (size.x < 0 || size.y < 0)
      abort("Panel size is negative: maybe too much separation?");

    currentpicture = new picture;
    size(size.x, size.y, keepAspect);
    currentpicture.T = t;
  }

  static void finishpanel(bool pop=true) {
    finish3d();
    limits(false, false);
    bool fs = currentpicture.xunitsize != 0 || currentpicture.yunitsize != 0;

    transform t = currentpicture.T * currentpicture.calculateTransform()
                * shift(fs ? (1, -1) : -plain.point(NW));
    currentpicture.T = identity;
    add(pic, currentpicture.fit(t), shift(pop ? grid.pop() : grid[-1])*0);

    currentpicture = pic;
  }

  static void overlay() {
    transform t = currentpicture.T;
    finishpanel(false);
    currentpicture = new picture;
    currentpicture.T = t;

    pair size = shiftless(grid[-1]) * (1, 1);
    currentpicture.xunitsize = 0.5*size.x;
    currentpicture.yunitsize = 0.5*size.y;
    draw(unitcircle, invisible);
  }

  static void finishgrid() {
    finishpanel();
    grid.delete(-1, 0);
    currentpicture = new picture;
    overlay();
  }

  static void clear() {
    if (grid.length != 0) {
      finishpanel();
      grid.delete();
      pic = new picture;
    }
  }
};
Grid.grid.cyclic = true;


void newgrid(real nx=1, real ny=1, pair sep=0) {
  Grid.newgrid(nx, ny, sep);
  Grid.newpanel();
}

void newpanel(real x=0, real y=0, pair scale=(1, 1), bool keepAspect=false,
              transform t=identity) {
  Grid.finishpanel();
  Grid.newpanel(x, y, scale.x, scale.y, keepAspect, t);
}

void finishgrid() {
  Grid.finishgrid();
}

void overlay() {
  Grid.overlay();
}

//   · Page ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
private picture finishpage() {
  static picture finalpicture;

  finish3d();
  limits(false, false);
  Grid.clear();
  if (!currentpicture.empty())
    add(finalpicture, currentpicture.fit(currentpicture.fixedscaling), 0, 0);

  picture pic;
  size(pic, currentpicture);
  currentpicture = pic;
  return finalpicture;
}

atexit(new void() {
  currentpicture = finishpage();
  exitfunction();
});

void newpage(picture) = null;
void newpage() {
  plain.newpage(finishpage());
}

//   · Sidebar «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
void palette(picture pic=currentpicture, Label L="", bounds bounds,
             real width = 4mm, real gap=1mm, axis axis=Right,
             pen[] palette=base_palette(-1), pen p=currentpen,
             paletteticks ticks=PaletteTicks, bool copy=true,
             bool antialias=false) {
  // if not already inside grid, create one and save it
  picture saved = currentpicture;
  if (Grid.grid.length == 0)
    newgrid();
  transform grid = Grid.grid[-1];

  // get direction of palette to be drawn
  pair dir = (new pair () {
    axisT axis;
    axis(pic, axis);
    return axis.align.dir;
  })();

  // according to direction, set palette and main picture dimensions
  pair size;
  transform t = grid;
  if (dir.y == 0) {
    saved.xsize -= width+gap;
    size = (width, saved.ysize);
    if (dir.x < 0)
      grid = shift(width+gap, 0) * grid;
    else
      t = shift(saved.xsize+gap, 0) * grid;
  } else {
    saved.ysize -= width+gap;
    size = (saved.xsize, width);
    if (dir.y > 0)
      grid = shift(0, -width-gap) * grid;
    else
      t = shift(0, -saved.ysize-gap) * grid;
  }

  // setup palette panel
  Grid.grid[-1] = t;
  currentpicture = new picture;
  size(size.x, size.y, false);
  currentpicture.scale.z = saved.scale.z;
  palette(currentpicture, L, bounds, (0, 0), (1, 1), axis, palette, p, ticks,
          copy, antialias);

  // get back to original picture;
  newpanel();
  currentpicture = saved;
  Grid.grid[-1] = grid;
}

// Data management «««««««««««««««««««««««««««««««««««««««««««««««««««««««««1
// Definitions «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
// 1D histograms «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««3
struct H1 {
  restricted real y[];
  restricted pair[] x, xe, ye, xSe, ySe;

  void operator init(pair x[], real y[], pair xe[]={}, pair ye[]={},
                     pair xSe[]={}, pair ySe[]={}) {
    this.x = copy(x);
    this.y = copy(y);
    this.xe = copy(xe);
    this.ye = copy(ye);
    this.xSe = copy(xSe);
    this.ySe = copy(ySe);
  }

  void operator init(real x[], real y[], pair xe[]={}, pair ye[]={},
                     pair xSe[]={}, pair ySe[]={}) {
    operator init(
      (x.length == y.length) ? x : I*x + (midpoints(x) .. 0),
    y, xe, ye, xSe, ySe);
  }

  real[] xc() { return map(xpart, x)[:y.length]; }
  real[] xb() { return map(ypart, x); }
  real[] xe() { return xe.length == 0 ? 0*y : map(xpart, xe); }
  real[] xE() { return xe.length == 0 ? 0*y : map(ypart, xe); }
  real[] ye() { return ye.length == 0 ? 0*y : map(xpart, ye); }
  real[] yE() { return ye.length == 0 ? 0*y : map(ypart, ye); }
  real[] xSe() { return xSe.length == 0 ? 0*y : map(xpart, xSe); }
  real[] xSE() { return xSe.length == 0 ? 0*y : map(ypart, xSe); }
  real[] ySe() { return ySe.length == 0 ? 0*y : map(xpart, ySe); }
  real[] ySE() { return ySe.length == 0 ? 0*y : map(ypart, ySe); }

  H1 add(real r)          { y += r; return this; }
  H1 multiply(real r)     { y *= r; return this; }
  H1 inverse()            { y = 1/y; return this; }
  H1 xscale(pair f(pair)) { x = map(f, x); return this; }
  H1 scale(real f(real))  { y = map(f, y); return this; }

  H1 transpose() {
    pair[] a = x, b = y;
    x = b;
    y = map(xpart, a);

    a = xe;
    b = ye;
    xe = b;
    ye = a;

    a = xSe;
    b = ySe;
    xSe = b;
    ySe = a;
    return this;
  }
};

// 2D histograms «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««3
struct H2 {
  restricted real[][] z, e;
  restricted pair[] x, y;

  void operator init(pair x[], pair y[], real z[][], real e[][]={}) {
    this.x = copy(x);
    this.y = copy(y);
    this.z = copy(z);
    this.e = copy(e);
  }

  void operator init(real x[], real y[], real z[][], real e[][]={}) {
    operator init(
      (x.length == z.length)    ? x : I*x + (midpoints(x) .. 0),
      (y.length == z[0].length) ? y : I*y + (midpoints(y) .. 0),
    z, e);
  }

  private real[] axis(pair x[], int n) {
    if (x.length != n)
      return map(ypart, x);
    real[] x = map(xpart, x);
    return midpoints(2*x[0]-x[1] .. x .. 2*x[x.length-1]-x[x.length-2]);
  }

  private H1 projection(pair x[], real y[], real a, real b, bool wt) {
    a = restrict(y[0], a, y[y.length-1]);
    b = restrict(y[0], b, y[y.length-1]);
    int i1 = restrict(0, search(y, a),   y.length-1);
    int i2 = restrict(0, search(y, b)+1, y.length-1);
    real w[] = wt ? (y[i1+1:i2] .. b) - max(a, y[i1:i2]) : array(i2-i1, 1);

    real[][] z, e;
    if (alias(this.x, x)) {
      z = transpose(map(new real[](real z[]) {return z[i1:i2];}, this.z));
      e = transpose(map(new real[](real z[]) {return z[i1:i2]^2;}, this.e));
    } else {
      z = this.z[i1:i2];
      e = this.e[i1:i2];
    }
    real e[] = e.length == w.length ? (w^2) * e : new real[];

    return H1(x, w*z, ye=map(sqrt, e));
  }

  real[] x() { return axis(x, z.length); }
  real[] y() { return axis(y, z[0].length); }

  H1 x(int keyword i) {return H1(y, z[i], ye=(1+I)*line(e, i));}
  H1 y(int keyword i) {return H1(x, column(z, i), ye=(1+I)*column(e, i));}

  H1 x(real x1, real x2=x1, bool weighting=false) {
    return projection(y, x(), x1, x2, weighting);
  }

  H1 y(real y1, real y2=y1, bool weighting=false) {
    return projection(x, y(), y1, y2, weighting);
  }

  H2 add(real r)          { z += r; return this; }
  H2 multiply(real r)     { z *= r; return this; }
  H2 inverse()            { z = 1/z; return this; }
  H2 xscale(pair f(pair)) { x = map(f, x); return this; }
  H2 yscale(pair f(pair)) { y = map(f, y); return this; }
  H2 scale(real f(real))  {
    z = map(new real[](real z[]) {return map(f, z);}, z);
    return this;
  }

  H2 transpose() {
    z = transpose(z);
    pair a[] = x;
    pair b[] = y;
    this.x = b;
    this.y = a;
    return this;
  }
}

// Data files ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««3
struct Data {
  restricted string header[][];
  restricted real   data[][];

  void operator init(string filename) {
    file fd = input(filename, false).line();
    if (error(fd))
      fd = process("xzcat " + filename + ".xz").line();

    // first read header
    for (string line, c="#"; !eof(fd) && c == "#";) {
      c = getc(fd);
      line = fd;

      if (c != "#")
        data.push((real[]) split(replace(c+=line, '\t', ' ')));
      else if (find(line, ":") > 1)
        header.push(split(replace(line, " ", ""), ':'));
    }
    header = transpose(header);

    // then read data
    while(!eof(fd))
      data.push(fd);
  }

  Data lines(... int idx[]) {
    Data d = new Data;
    d.header = header;
    d.data = sequence(new real[](int i) {return data[idx[i]];}, idx.length);
    return d;
  }

  Data columns(... int idx[]) {
    Data d = new Data;
    d.header = header;
    d.data = map(new real[](real x[]) {
      return sequence(new real(int i) {return x[idx[i]];}, idx.length);
    }, data);
    return d;
  }

  Data range(int x1, int x2) {
    Data d = new Data;
    d.header = header;
    d.data = data[x1:x2];
    return d;
  }

  Data transpose() {
    Data d = new Data;
    d.header = header;
    d.data = transpose(data);
    return d;
  }

  string get(string name) {
    int i = header.length > 0 ? find(header[0] == name) : -1;
    return i<0 ? '' : header[1][i];
  }
}

H1 operator cast(Data data) {
  string fmt[] = {"x","y","-dx","+dx","-dy","+dy","-sx","+sx","-sy","+sy"};
  real d[][] = new real[fmt.length][];

  string formats[] = split(data.get("format"), ',');
  if (formats.length == 1)
    d[0:data.data[0].length] = transpose(data.data);
  else {
    int idx = -1;
    for (string f : formats)
      d[find(fmt==f)] = column(data.data, ++idx);
  }

  return H1(d[0], d[1], d[2]+d[3]*I, d[4]+d[5]*I, d[6]+d[7]*I, d[8]+d[9]*I);
}

H1[] operator cast(Data data) {
  string formats[] = split(data.get("format"), ',');

  if (formats.length == 1)
    return sequence(new H1(int i) {
      return data.columns(0, i+1);
    }, data.data[0].length-1);

  real xi[] = column(data.data, find(split(data.get("format"), ',') == 'x'));

  int splits[] = {0};
  for (int i = 1; i < xi.length; ++i)
    if (xi[i] < xi[i-1])
      splits.push(i);
  splits.push(xi.length);

  return sequence(new H1(int i) {
    return data.range(splits[i], splits[i+1]);
  }, splits.length-1);
}

H2 operator cast(Data data) {
  real x[], y[], z[][], e[][], d[][] = data.data;

  if (d[0].length == d[2].length - 1) {
    x = d[0];
    y = column(d[1:], 0);
    z = map(new real[](real x[]) {return x[1:];}, d[1:]);
  }
  else {
    if (d[0].length * d[1].length != d[2].length)
      d = transpose(d);
    x = unique(d[0], false);
    y = unique(d[1], false);
    z = balance(d[2], x.length, y.length);
    if (d.length == 4)
      e = balance(d[3], x.length, y.length);
  }

  return H2(x, y, z, e);
}

// Operators «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
H1 copy(H1 h) { return H1(h.x, h.y, h.xe, h.ye, h.xSe, h.ySe); }
H1 operator +(H1 h, real r) { h = copy(h); return h.add(r); }
H1 operator -(H1 h, real r) { h = copy(h); return h.add(-r); }
H1 operator *(H1 h, real r) { h = copy(h); return h.multiply(r); }
H1 operator /(H1 h, real r) { h = copy(h); return h.multiply(1/r); }
H1 operator -(real r, H1 h) { h = copy(h); return h.multiply(-1).add(r); }
H1 operator /(real r, H1 h) { h = copy(h); return h.inverse().multiply(r); }
H1 operator +(real r, H1 h) { return h+r; }
H1 operator *(real r, H1 h) { return h*r; }
H1 operator -(H1 h)         { return -1*h;}

H2 copy(H2 h) { return H2(h.x, h.y, h.z, h.e); }
H2 operator +(H2 h, real r) { h = copy(h); return h.add(r); }
H2 operator -(H2 h, real r) { h = copy(h); return h.add(-r); }
H2 operator *(H2 h, real r) { h = copy(h); return h.multiply(r); }
H2 operator /(H2 h, real r) { h = copy(h); return h.multiply(1/r); }
H2 operator -(real r, H2 h) { h = copy(h); return h.multiply(-1).add(r); }
H2 operator /(real r, H2 h) { h = copy(h); return h.inverse().multiply(r); }
H2 operator +(real r, H2 h) { return h+r; }
H2 operator *(real r, H2 h) { return h*r; }
H2 operator -(H2 h)         { return -1*h;}

// Plotting ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««2
void histogram(picture pic=currentpicture, H1 h, real low=-infinity,
               pen fillpen=nullpen, pen drawpen=nullpen, bool bars=false,
               Label legend="", real msize=legendmarkersize) {
  histogram(pic, h.xb(), h.y, low, fillpen, drawpen, bars, legend, msize);
}

guide[] graph(picture pic=currentpicture, H1 h, bool3 cond(real)=null,
              interpolate join=operator --) {
  real x[] = h.xc();
  return cond == null
    ? new guide[] {graph(pic, x, h.y, join)}
    : graph(pic, x, h.y, map(cond, x), join);
}

void errorbars(picture pic=currentpicture, H1 h, bool3 cond(real)=null,
               pen p=currentpen, real size=0) {
  real x[] = h.xc();
  bool c[] = cond == null ? new bool[] {} : map(cond, x);
  errorbars(pic, x, h.y, h.xE(), h.yE(), h.xe(), h.ye(), c, p, size);
}

void errorblocks(picture pic=currentpicture, H1 h, bool3 cond(real)=null,
               pen p=currentpen, real size=0) {
  real x[] = h.xc();
  bool c[] = cond == null ? new bool[] {} : map(cond, x);
  errorblocks(pic, x, h.y, h.xSE(), h.ySE(), h.xSe(), h.ySe(), c, p, size);
}

bounds image(picture pic=currentpicture, H2 f, range range=Automatic,
             int nx=ngraph, int ny=nx, pen[] p, bool copy=true,
             bool antialias=false) {
  real[] x=f.x(), y=f.y();
  pair m = (x[0], y[0]);
  pair M = (x[x.length-1], y[y.length-1]);

  static bool uniform(real x[]) {
    return all(abs(1-1/(x[1]-x[0])*(x[1:]-x[:x.length-1])) < 100realEpsilon);
  }
  if (uniform(x) && uniform(y))
    return image(pic, f.z, range, m, M, p, true, copy, antialias);

  return image(pic, new real(real x0, real y0) {
      int i = restrict(0, search(x, x0), x.length-1);
      int j = restrict(0, search(y, y0), y.length-1);
      return f.z[i][j];
  }, range, m, M, nx, ny, p, antialias);
}

guide[][] contour(H2 f, real[][] midpoint=new real[][], real[] c,
                  interpolate join=operator --) {
  pair z[][] = new pair[f.z.length][];

  for (int i : sequence(f.z.length))
    for (int j : sequence(f.z[0].length))
      z[i][j] = (f.x[i].x, f.y[j].x);

  return contour(z, f.z, midpoint, c, join);
}

surface surface(picture pic=currentpicture, H2 h,
                splinetype xsplinetype=null,
                splinetype ysplinetype=xsplinetype, bool[][] cond={}) {
  real x[] = map(xpart, h.x)[:h.z.length];
  real y[] = map(xpart, h.y)[:h.z[0].length];
  return surface(pic, h.z, x, y, xsplinetype, ysplinetype, cond);
}

bounds image(picture pic=currentpicture, surface s, range range=Automatic,
             int nu=1, int nv=1, pen[] p, material surfacepen=currentpen,
             pen meshpen=nullpen, light light=currentlight,
             light meshlight=nolight, string name="",
             render render=defaultrender, bool3 copy=default) {
  if (copy != false) {
    p = copy(p);
    if (copy == true)
      s = surface(s);
  }

  scalefcn Tinv = pic.scale.z.Tinv;
  real f[][] = s.map(new real(triple v) { return Tinv(zpart(v)); });
  real m = min(f);
  real M = max(f);
  bounds bounds = range(pic,m,M);
  real rmin=pic.scale.z.T(bounds.min);
  real rmax=pic.scale.z.T(bounds.max);
  p = adjust(pic,m,M,rmin,rmax,p);

  // Crop data to allowed range and scale
  if (range != Full || pic.scale.z.scale.T != identity ||
      pic.scale.z.postscale.T != identity) {
    scalefcn T = pic.scale.z.T;
    real m = bounds.min;
    real M = bounds.max;
    for(int i = 0; i < f.length; ++i)
      f[i] = map(new real(real x) {return T(min(max(x, m), M));}, f[i]);
  }

  s.colors(palette(f, p));
  draw(pic, s, nu, nv, surfacepen, meshpen, light, meshlight, name, render);
  return bounds;
}

// vim: foldmarker=«,»
