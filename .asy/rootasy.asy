// vim: tw=0
// rootasy module: create interface between ROOT and Asymptote
private import graph;
private import graph3;
private import stats;
private import palette;
private import contour;

real barscale = 6;

// Parse user as array of strings
string[] user = split(settings.user,";");
user.pop();

// {{{1 Common structs
struct ipair {
  int x;
  int y;
  void operator init(int x, int y)
  { this.x = x; this.y = y; }
  ipair operator cast(pair a)
  { return ipair(floor(a.x),floor(a.y)); }
};
struct itriple {
  int x;
  int y;
  int z;
  void operator init(int x, int y, int z)
  { this.x = x; this.y = y; this.z = z; }
  itriple operator cast(triple a)
  { return itriple(floor(a.x),floor(a.y),floor(a.z)); }
};
//}}} Common structs
//{{{1 Basic Math functions
real average(real[] v)
{
  if (v.length == 0) return 0;

  real avg = 0;
  for (int i = 0; i < v.length; ++i)
    avg += v[i];
  return avg/v.length;
}

real average(real[][] A, ipair x, ipair y)
{ // takes average of portion of a matrix
  x.x = x.x < 0 ? 0 : min(x.x, A.length-1);
  y.x = y.x < 0 ? 0 : min(y.x, A[0].length-1);
  x.y = x.y < 0 ? 0 : min(x.y, A.length);
  y.y = y.y < 0 ? 0 : min(y.y, A[0].length);

  int nx = x.y-x.x;
  int ny = y.y-y.x;

  real average = 0.;
  for (int i = 0; i < nx; ++i)
    for (int j = 0; j < ny; ++j)
      average += A[i+x.x][j+y.x]/(nx*ny);
  return average;
}
transform swap=(0,0,0,1,1,0);
transform3 permute(int[] perm)
{
  if (perm.length != 3 || !all(sort(perm) == new int[] {0,1,2}))
    abort("Cannot perform permutation: incorrect perm array");

  real[][] T = diagonal(0,0,0,1);
  T[0][perm[0]] = 1;
  T[1][perm[1]] = 1;
  T[2][perm[2]] = 1;

  return T;
}
real[][] operator ^(real[][] M, real x)
{
  real[][] R = copy(M);
  for (int i = 0; i < R.length; ++i)
    R[i] = R[i]^x;
  return R;
}
//}}}
//{{{2 Axes
ticks gridticks = Ticks(pTick=opacity(0.1),ptick=opacity(0.1),extend=true);
void simplegrid(Label Lx="$x$", Label Ly="$y$", pair dir=SW)
{
  unitsize(100cm/(point(N).y-point(S).y)); // fix scaling
  bool left = dir.x < 0;
  bool bottom = dir.y < 0;
  bool logx = currentpicture.scale.x.scale.logarithmic;
  bool logy = currentpicture.scale.y.scale.logarithmic;
  real Size = Ticksize;
  real size = ticksize;

  // Draw grid
  xaxis(LeftRight,Ticks(logx?"%":"\phantom{$%.4g$}",beginlabel=false,endlabel=false,pTick=0.5+opacity(0.1),ptick=0.5+opacity(0.1),extend=true),above=true);
  yaxis(BottomTop,Ticks(logy?"%":"\phantom{$%.4g$}",beginlabel=false,endlabel=false,pTick=0.5+opacity(0.1),ptick=0.5+opacity(0.1),extend=true),above=true);

  // Draw x axes
  if (bottom) {
    xaxis(Lx,Bottom,LeftTicks(Size=Size,size=size),above=true); // bottom
    xaxis(Right,RightTicks(logx?"%":"\phantom{$%.4g$}",beginlabel=false,endlabel=false,Size=Size,size=size),above=true); // top invisible
  }
  else {
    xaxis(Left,LeftTicks(logx?"%":"\phantom{$%.4g$}",beginlabel=false,endlabel=false,Size=Size,size=size),above=true); // bottom invisible
    xaxis(Lx,Top,RightTicks(Size=Size,size=size),above=true); // top
  }

  // Draw y axes
  if (left) {
    yaxis(Ly,Left,RightTicks(Size=Size,size=size),above=true); // left
    yaxis(Top,LeftTicks(logy?"%":"\phantom{$%.4g$}",beginlabel=false,endlabel=false,Size=Size,size=size),above=true); // right invisible
  }
  else {
    yaxis(Bottom,RightTicks(logy?"%":"\phantom{$%.4g$}",beginlabel=false,endlabel=false,Size=Size,size=size),above=true); // left invisible
    yaxis(Ly,Right,LeftTicks(Size=Size,size=size),above=true); // right
  }
}

void polargrid(Label L="r", real dt = pi/6, pen gp=opacity(0.1))
{
  pair[] ticks;

  // Get picture boundary
  path bound = point(SW)--point(NW)--point(NE)--point(SE)--cycle;

  // Draw radial lines and get ticks coordinates
  for (real t=0; t<=pi-0.5dt; t+=dt){
    pair dir = (cos(t),sin(t));
    real[] inter = intersections(bound,(0,0),dir);
    if (inter.length == 2){
      draw(point(bound,inter[0])--point(bound,inter[1]),gp);
      ticks.push(point(bound,inter[0]));
      ticks.push(point(bound,inter[1]));
    }
  }

  // Find angle axes points
  real xmax,ymax,xmin,ymin;
  real[] top,bottom,left,right;

  if (ticks.length != 0){
    xmin = xmax = ticks[0].x;
    ymin = ymax = ticks[0].y;
  }

  for (pair p : ticks){
    xmin = min(xmin,p.x);
    xmax = max(xmax,p.x);
    ymin = min(ymin,p.y);
    ymax = max(ymax,p.y);
  }

  for (pair p: ticks){
    if (abs(p.y - ymin) < 1e-12 && p.x < -1e-12) bottom.push(p.x);
    if (abs(p.y - ymax) < 1e-12) top.push(p.x);
    if (abs(p.x - xmin) < 1e-12) left.push(p.y);
    if (abs(p.x - xmax) < 1e-12) right.push(p.y);
  }

  // Draw angle axes
  xaxis(Bottom,LeftTicks(new string(real x){
    return format("$%.1f^\circ$",180 + 180/pi*acos(-x/sqrt(x**2+ymin**2)));
    },bottom,invisible));
  xaxis(Top,RightTicks(new string(real x){
    return format("$%.1f^\circ$",180/pi*acos(x/sqrt(x**2+ymax**2)));
    },top,invisible));
  yaxis(Left,RightTicks(new string(real y){
    return format("$%.1f^\circ$",180 + 180/pi*atan(y/xmin));
    },left,invisible));
  yaxis(Right,LeftTicks(new string(real y){
    return format("$%.1f^\circ$",(y>=0 ? 0 : 360) + 180/pi*atan(y/xmax));
    },right,invisible));

  // Find good radial divisor
  real raxisminstep = 0.8cm * xmax/point(E,false).x;
  real div;
  for (div = 1; ceil(raxisminstep/div) > 1; div*=10);
  for (; ceil(5*raxisminstep/div) <= 1; div/=5);
  for (; ceil(2*raxisminstep/div) <= 1; div/=2);
  real dr = div;

  // Draw radial grid
  bool drawed = true;
  for (real r=dr; drawed == true; r+=dr){
    drawed = false;
    real tmin,tmax;

    // 1 Quad.
    tmin = xmax<=0 ? 90 : xmax<r ? aCos(xmax/r) : 0;
    tmin = max(tmin,ymin<=0 ? 0 : ymin<r ? aSin(ymin/r) : 90);
    tmax = ymax<=0 ? 0 : ymax<r ? aSin(ymax/r) : 90;
    tmax = min(tmax,xmin<=0 ? 90 : xmin<r ? aCos(xmin/r) : 0);
    if (tmin < tmax){
      draw(Arc((0,0),r,tmin,tmax),gp);
      drawed = true;
    }

    // 2 Quad.
    tmin = 180 - tmax;
    tmin = max(tmin,xmax>=0 ? 90 : -xmax<r ? aCos(xmax/r) : 180);
    tmax = xmin>=0 ? 90 : -xmin<r ? aCos(xmin/r) : 180;
    tmax = min(tmax,ymin<=0 ? 180 : ymin<r ? 180 - aSin(ymin/r) : 90);
    if (tmin < tmax){
      draw(Arc((0,0),r,tmin,tmax),gp);
      drawed = true;
    }

    // 3 Quad.
    tmin = 360 - tmax;
    tmin = max(tmin,ymax>=0 ? 180 : -ymax<r ? 180 - aSin(ymax/r) : 270);
    tmax = ymin>=0 ? 180 : -ymin<r ? 180 - aSin(ymin/r) : 270;
    tmax = min(tmax,xmax>=0 ? 270 : -ymax<r ? 360 - aCos(xmax/r) : 180);
    if (tmin < tmax){
      draw(Arc((0,0),r,tmin,tmax),gp);
      drawed = true;
    }

    // 4 Quad.
    tmin = 540 - tmax;
    tmin = max(tmin,xmin<=0 ? 270 : xmin<r ? 360 - aCos(xmin/r) : 360);
    tmax = ymax>=0 ? 360 : -ymax<r ? 360 + aSin(ymax/r) : 270;
    tmax = min(tmax,xmax<=0 ? 270 : xmax<r ? 360 - aCos(xmax/r) : 360);
    if (tmin < tmax){
      draw(Arc((0,0),r,tmin,tmax),gp);
      drawed = true;
    }
  }

  // Draw radial axis
  real[] raxis;
  for (real r=0.; r<xmax; r+=dr)
    raxis.push(r);
  xaxis(Label(L,Relative((0.5(xmax+(xmin>0 ? xmin : 0))-xmin)/(xmax-xmin))),Bottom,LeftTicks(raxis));
}
//}}}
//{{{1 Safelog functions

// GRAPH
guide[] graph_safelog(picture pic=currentpicture, real[] x, real[] y, bool3[] cond, interpolate join=operator --)
{
  x = x[:];
  y = y[:];
  cond = cond[:];

  bool xlog = pic.scale.x.scale.logarithmic;
  bool ylog = pic.scale.y.scale.logarithmic;

  for (int i = 0; i < cond.length; ++i)
    if ((xlog && x[i] <= 0) || (ylog && y[i] <= 0))
      cond[i] = false;

  return graph(pic,x,y,cond,join);
}

// ERROR BARS
arrowbar BarsType(int type, real size)
{
  if (type == 0) return None;
  else if (type == 1) return BeginBar(size);
  else if (type == 2) return EndBar(size);
  else return Bars(size);
}

void errorbar(picture pic, pair z, pair dp, pair dm, pen p, int xtype, int ytype, real size)
{
  real dmx=-abs(dm.x);
  real dmy=-abs(dm.y);
  real dpx=abs(dp.x);
  real dpy=abs(dp.y);
  if(dmx != dpx) draw(pic,Scale(pic,z+(dmx,0))--Scale(pic,z+(dpx,0)),p,
                      BarsType(xtype,size));
  if(dmy != dpy) draw(pic,Scale(pic,z+(0,dmy))--Scale(pic,z+(0,dpy)),p,
                      BarsType(ytype,size));
}

void errorbars_safelog(picture pic=currentpicture, real[] x, real[] y,
               real[] dpx, real[] dpy, real[] dmx={}, real[] dmy={},
               bool[] cond={}, pen p=currentpen, real size=0)
{
  bool logx = pic.scale.x.scale.logarithmic;
  bool logy = pic.scale.y.scale.logarithmic;
  dmx = dmx[:];
  dpx = dpx[:];
  dmy = dmy[:];
  dpy = dpy[:];
  if(dmx.length == 0) dmx=copy(dpx);
  if(dmy.length == 0) dmy=copy(dpy);
  int n=x.length;
  checklengths(n,y.length);
  checklengths(n,dpx.length);
  checklengths(n,dpy.length);
  checklengths(n,dmx.length);
  checklengths(n,dmy.length);
  cond = cond[:];
  if (cond.length == 0) cond = array(n,true);
  checkconditionlength(cond.length,n);

  // Remove points not suitable for log scale
  real xmin = max(x), ymin = max(y);
  for (int i = 0; i < n; ++i) {
    if ((logx && x[i] <= 0) || (logy && y[i] <= 0))
      cond[i] = false;
    else {
      xmin = min(xmin,x[i]);
      if (logx && x[i] - dmx[i] > 0)
        xmin = min(xmin,x[i]-dmx[i]);
      ymin = min(ymin,y[i]);
      if (logy && y[i] - dmy[i] > 0)
        ymin = min(ymin,y[i]-dmy[i]);
    }
  }
  xmin /= 2;
  ymin /= 2;

  // Set bars type for each point
  int[] xtype = array(n,3);
  int[] ytype = array(n,3);
  for (int i = 0; i < n; ++i)
    if (cond[i]) {
      if (logx && x[i] - dmx[i] < xmin) {
        dmx[i] = x[i] - xmin;
        xtype[i] = 2;
      }
      if (logy && y[i] - dmy[i] < ymin) {
        dmy[i] = y[i] - ymin;
        ytype[i] = 2;
      }
    }

  for(int i=0; i < n; ++i) {
    if(cond[i])
      errorbar(pic,(x[i],y[i]),(dpx[i],dpy[i]),(dmx[i],dmy[i]),p,xtype[i],ytype[i],size);
  }
}

// ERROR RANGE
void errorrange_safelog(picture pic=currentpicture, real[] x, real[] y,
                real[] dpy, real[] dmy={},
                bool[] cond, pen fill=currentpen, pen border=currentpen)
{
  x = x[:];
  bool logx = pic.scale.x.scale.logarithmic;
  bool logy = pic.scale.y.scale.logarithmic;
  if(dmy.length == 0) dmy=copy(dpy);
  int n=x.length;
  checklengths(n,y.length);
  checklengths(n,dpy.length);
  checklengths(n,dmy.length);
  if (cond.length == 0) cond = array(n,true);
  checkconditionlength(cond.length,n);

  real[] yup = y + dpy;
  real[] ydn = y - dmy;

  // Remove points not suitable for log scale
  real ymin = max(y);
  for (int i = n-1; i >= 0; --i) {
    if ((!cond[i]) || (logx && x[i] <= 0) || (logy && yup[i] <= 0)) {
      x.delete(i);
      yup.delete(i);
      ydn.delete(i);
      --n;
    }
    else {
      if (y[i] > 0)
        ymin = min(ymin,y[i]);
      if (logy && ydn[i] > 0)
        ymin = min(ymin,ydn[i]);
    }
  }
  ymin /= 2;

  // Fix lower bound for log scale
  if (logy)
    for (int i = 0; i < n; ++i)
      if (ydn[i] <= 0) ydn[i] = ymin;

  // Setup upper and lower limits and draw them
  path up = graph(pic,x,yup);
  path dn = graph(pic,x,ydn);
  path filled = up -- reverse(dn) -- cycle;
  fill(filled,fill);
  draw(pic,up,border);
  draw(pic,dn,border);
}

// ERROR BLOCK
void drawvbox(picture pic, pair pos, real width, real hlo, real hhi, pen p, int type)
{
  pic.add(new void(frame f, transform t) {
    picture opic;
    path left   = (t*Scale(pic,pos+(0,hlo)) - (0.5*width,0)) -- (t*Scale(pic,pos+(0,hhi)) - (0.5*width,0));
    path right  = (t*Scale(pic,pos+(0,hlo)) + (0.5*width,0)) -- (t*Scale(pic,pos+(0,hhi)) + (0.5*width,0));
    path top    = (t*Scale(pic,pos+(0,hhi)) - (0.5*width,0)) -- (t*Scale(pic,pos+(0,hhi)) + (0.5*width,0));
    path bottom = (t*Scale(pic,pos+(0,hlo)) - (0.5*width,0)) -- (t*Scale(pic,pos+(0,hlo)) + (0.5*width,0));
    draw(opic, left, p=p);
    draw(opic, right, p=p);
    if (type == 3) {
      draw(opic, top, p=p);
      draw(opic, bottom, p=p);
    }
    else if (type == 2)
      draw(opic, top, p=p);
    else if (type == 1)
      draw(opic, bottom, p=p);
    add(f, opic.fit());
  });
  pic.addBox(Scale(pic,pos+(0,hlo)), Scale(pic,pos+(0,hhi)), (-0.5*width,0)+min(p), (0.5*width,0)+max(p));
}

void drawhbox(picture pic, pair pos, real wlo, real whi, real height, pen p, int type)
{
  pic.add(new void(frame f, transform t) {
    path left   = (t*Scale(pic,pos+(wlo,0)) - (0,0.5*height)) -- (t*Scale(pic,pos+(wlo,0)) + (0,0.5*height));
    path right  = (t*Scale(pic,pos+(whi,0)) - (0,0.5*height)) -- (t*Scale(pic,pos+(whi,0)) + (0,0.5*height));
    path top    = (t*Scale(pic,pos+(wlo,0)) + (0,0.5*height)) -- (t*Scale(pic,pos+(whi,0)) + (0,0.5*height));
    path bottom = (t*Scale(pic,pos+(wlo,0)) - (0,0.5*height)) -- (t*Scale(pic,pos+(whi,0)) - (0,0.5*height));
    picture opic;
    draw(opic, top, p=p);
    draw(opic, bottom, p=p);
    if (type == 3) {
      draw(opic, left, p=p);
      draw(opic, right, p=p);
    }
    else if (type == 2)
      draw(opic, right, p=p);
    else if (type == 1)
      draw(opic, left, p=p);
    add(f, opic.fit());
  });
  pic.addBox(Scale(pic,pos+(wlo,0)), Scale(pic,pos+(whi,0)), (0,-0.5*height)+min(p), (0,0.5*height)+max(p));
}

void drawbox(picture pic, pair pos, real wlo, real whi, real hlo, real hhi, pen p, int xtype, int ytype)
{
  pair a,b,c,d;
  a = Scale(pic,pos + (wlo,hlo));
  b = Scale(pic,pos + (wlo,hhi));
  c = Scale(pic,pos + (whi,hhi));
  d = Scale(pic,pos + (whi,hlo));

  if (xtype == 3) {
    draw(pic,a--b,p=p);
    draw(pic,c--d,p=p);
  }
  else if (xtype == 2)
    draw(pic,c--d,p=p);
  else if (xtype == 1)
    draw(pic,a--b,p=p);

  if (ytype == 3) {
    draw(pic,b--c,p=p);
    draw(pic,d--a,p=p);
  }
  else if (ytype == 2)
    draw(pic,b--c,p=p);
  else if (ytype == 1)
    draw(pic,c--a,p=p);
}

void errorblock(picture pic, pair z, pair dp, pair dm, pen p, int xtype, int ytype, real size)
{
  real dmx=-abs(dm.x);
  real dmy=-abs(dm.y);
  real dpx=abs(dp.x);
  real dpy=abs(dp.y);
  if (dmx != dpx && dmy != dpy)
    drawbox(pic,z,dmx,dpx,dmy,dpy,p,xtype,ytype);
  else {
    if (dmx != dpx) drawhbox(pic,z,dmx,dpx,size,p,xtype);
    if (dmy != dpy) drawvbox(pic,z,size,dmy,dpy,p,ytype);
  }
}

void errorblocks_safelog(picture pic=currentpicture, real[] x, real[] y,
               real[] dpx, real[] dpy, real[] dmx={}, real[] dmy={},
               bool[] cond={}, pen p=currentpen, real size=3)
{
  bool logx = pic.scale.x.scale.logarithmic;
  bool logy = pic.scale.y.scale.logarithmic;
  dmx = dmx[:];
  dpx = dpx[:];
  dmy = dmy[:];
  dpy = dpy[:];
  if(dmx.length == 0) dmx=copy(dpx);
  if(dmy.length == 0) dmy=copy(dpy);
  int n=x.length;
  checklengths(n,y.length);
  checklengths(n,dpx.length);
  checklengths(n,dpy.length);
  checklengths(n,dmx.length);
  checklengths(n,dmy.length);
  if (cond.length == 0) cond = array(n,true);
  checkconditionlength(cond.length,n);

  // Remove points not suitable for log scale
  real xmin = max(x), ymin = max(y);
  for (int i = 0; i < n; ++i) {
    if ((logx && x[i] <= 0) || (logy && y[i] <= 0))
      cond[i] = false;
    else {
      xmin = min(xmin,x[i]);
      if (logx && x[i] - dmx[i] > 0)
        xmin = min(xmin,x[i]-dmx[i]);
      ymin = min(ymin,y[i]);
      if (logy && y[i] - dmy[i] > 0)
        ymin = min(ymin,y[i]-dmy[i]);
    }
  }
  xmin /= 2;
  ymin /= 2;

  // Set bars type for each point
  int[] xtype = array(n,3);
  int[] ytype = array(n,3);
  for (int i = 0; i < n; ++i)
    if (cond[i]) {
      if (logx && x[i] - dmx[i] < xmin) {
        dmx[i] = x[i] - xmin;
        xtype[i] = 2;
      }
      if (logy && y[i] - dmy[i] < ymin) {
        dmy[i] = y[i] - ymin;
        ytype[i] = 2;
      }
    }

  for(int i=0; i < n; ++i) {
    if(cond[i])
      errorblock(pic,(x[i],y[i]),(dpx[i],dpy[i]),(dmx[i],dmy[i]),p,xtype[i],ytype[i],size);
  }
}

// IMAGE
bounds image_safelog(picture pic = currentpicture, real f(real, real),
  range range = Full, pair initial, pair final, int nx=300, int ny=nx,
  pen[] palette, bool antialias = false, real pos_min = 1)
{
  real eval(real,real);
  if (pic.scale.z.scale.logarithmic) eval = new real (real x, real y) {
    real z = f(x,y);
    if (z <= 0) return pos_min;
    return z;
  };
  else eval = f;
  return image(pic,eval,range,initial,final,nx,ny,palette,antialias);
}

// CONTOUR
guide[][] contour(picture pic, real f(real, real), pair initial, pair final, real[] c, int nx=ngraph, int ny=nx, interpolate join=operator --)
{
  guide[][] base = contour(f,initial,final,c,nx,ny,join);
  guide[][] contour;

  for (guide[] aux : base) {
    contour.push(new guide[]);
    for (guide aux2 : aux) {
      guide scaledg;
      for (int i = 0; i < size(aux2); ++i)
        scaledg = join(scaledg,Scale(pic,point(aux2,i)));
      contour[contour.length-1].push(scaledg);
    }
  }
  return contour;
}

// SURFACE
surface surface_safelog(picture pic=currentpicture, real f(real, real), pair a, pair b, int nu=100, int nv=nu, bool spline = true)
{
  triple eval(pair z) { return Scale(pic,(z.x,z.y,f(z.x,z.y))); };

  if (pic.scale.z.scale.logarithmic) {
    bool cond(pair z) { return f(z.x,z.y) > 0; }
    if (spline)
      return surface(eval,a,b,nu,nv,Spline,cond);
    return surface(eval,a,b,nu,nv,cond);
  }

  if (spline)
    return surface(eval,a,b,nu,nv,Spline);
  return surface(eval,a,b,nu,nv);
}

surface surface_safelog_matrix(picture pic=currentpicture, real f(real, real), pair a, pair b, int nu=100, int nv=nu, bool spline = true)
{
  a = Scale(pic,a);
  b = Scale(pic,b);

  triple eval(pair z)
  {
    real x = pic.scale.x.scale.Tinv(z.x);
    real y = pic.scale.y.scale.Tinv(z.y);
    real v = pic.scale.z.scale.T(f(x,y));
    return (z.x,z.y,v);
  }
  bool cond (pair z)
  {
    real x = pic.scale.x.scale.Tinv(z.x);
    real y = pic.scale.y.scale.Tinv(z.y);
    if (pic.scale.z.scale.logarithmic)
      return f(x,y) > 0;
    return true;
  }

  if (spline)
    return surface(eval,a,b,nu,nv,Spline);
  return surface(eval,a,b,nu,nv);
}
//}}}
//{{{1 Root objects
//{{{2 TVector
real[] TVector(string fileobj, int version=9999, bool keep=false)
{
  string file = substr(fileobj,0,find(fileobj,".root")+5);
  string name = substr(fileobj,find(fileobj,".root")+6);
  string command = "rootasy " + file + " get " + name + "," + string(version);
  string binfile = file + "-" + replace(name,"/","-") + "," + string(version) + ".bin";

  // Extract from .root file
  if (keep) {
    file fd = input(binfile,false);
    if (error(fd))
      system(command);
    close(fd);
  }
  else system(command);

  // Read data
  file fd = input(binfile,mode="xdr");
  real[] data = fd;
  if (!keep) delete(binfile);
  return data;
}
//}}}2
// {{{2 TH1 struct
struct TH1 {
  // {{{3 Internal structs
  struct error {
    real[] x;
    real[] y;
    real[] X;
    real[] Y;
  };
  // }}}
  // {{{3 Members
  private real[] x;       // Bin delimiters (or graph x coordinate)
  private real[] y;       // Bin contents
  private error syst;     // Systematic errors
  private error stat;     // Statistical errors
  private int size;       // Size of histogram (number of bins)
  private pair limits;    // X axis range
  private bool3[] cond;   // Show/hide for each point
  private string name;    // Name or title for referring experimental data
  private string cite;    // Mendelay citation key
  // }}}
  // {{{3 Get properties routines
  real[] getX() { return this.x; }
  real[] getY() { return this.y; }
  real[] getyE() { return this.stat.y; }
  real[] getYE() { return this.stat.Y; }
  string getName() { return this.name; }
  string getCite() { return this.cite; }
  int getSize() { return this.size; }
  real lowerBound() { return this.limits.x; }
  real upperBound() { return this.limits.y; }
  real getMax() { return max(this.y); }
  private real getMinPos()
  {
    real min = getMax();
    for (int i = 0; i < this.y.length; ++i)
      min = (this.y[i] > 0 && this.y[i] < min) ? this.y[i] : min;
    return min;
  }
  real getMin(bool positive = false)
  {
    if (positive) return getMinPos();
    return min(this.y);
  }
  real[] getXcenter()
  { // Return array containing the center of each bin
    if (this.x.length == this.y.length) return this.x;

    real[] x;
    for (int i = 1; i < this.x.length; ++i) {
      x.push(0.5*(this.x[i] + this.x[i-1]));
    }
    return x;
  }
  // }}}
  // {{{3 Object Constructors
  void operator init(string name = "", string cite = "", real[] x, real[] y,
                     real[] exm = new real[], real[] exM = new real[], real[] eym = new real[], real[] eyM = new real[],
                     real[] Sexm = new real[], real[] SexM = new real[], real[] Seym = new real[], real[] SeyM = new real[])
  {
    this.name = name;
    this.cite = cite;
    this.size = y.length;
    this.y = y[:];
    this.syst.x = Sexm.length != 0 ? Sexm[:] : array(y.length,0);
    this.syst.X = SexM.length != 0 ? SexM[:] : array(y.length,0);
    this.syst.y = Seym.length != 0 ? Seym[:] : array(y.length,0);
    this.syst.Y = SeyM.length != 0 ? SeyM[:] : array(y.length,0);
    this.stat.x = exm.length != 0 ? exm[:] : array(y.length,0);
    this.stat.X = exM.length != 0 ? exM[:] : array(y.length,0);
    this.stat.y = eym.length != 0 ? eym[:] : array(y.length,0);
    this.stat.Y = eyM.length != 0 ? eyM[:] : array(y.length,0);
    this.cond = array(y.length,true);

    // X axis
    if (x.length != y.length) { // histogram
      this.limits = (x[0], x[x.length-1]);
      this.x = x[:];
    }
    else { // Graph
      real delta = x[1] - x[0];
      int i = 2;
      while (i < x.length && x[i] - x[i-1] == delta)
        ++i;
      if (i < x.length) { // Partition is not uniform
        this.limits = (x[0], x[x.length-1]);
        this.x = x[:];
      }
      else { // Uniform partition, save as histogram
        this.limits = (x[0] - 0.5*delta, x[x.length-1] + 0.5*delta);
        for (i = 0; i < x.length; ++i)
          this.x.push(x[i] - 0.5*delta);
        this.x.push(this.limits.y);
      }
    }
  }

  private void readTXT(string filename, string formats, bool header)
  {
    file fd = input(filename);
    string name;
    string cite;
    if (header) {
      int current = 0;
      string line = fd;
      while (!eof(fd) && find(line, "#") == 0) {
        string[] values = split(line,": ");
        if (values[0] == "# format") formats = values[1];
        else if (values[0] == "# name") name = values[1];
        else if (values[0] == "# cite") cite = values[1];
        current = tell(fd);
        line = fd;
      }
      seek(fd, current);

      //for (string line = fd; !eof(fd) && line != "END"; line = fd) {
      //  string[] values = split(line,": ");
      //  if (values[0] == "# format") formats = values[1];
      //  else if (values[0] == "name") name = values[1];
      //  else if (values[0] == "cite") cite = values[1];
      //}
    }
    if (formats == "") abort("I cannot understand this file.");
    string[] format = split(formats,",");

    // Find columns
    int x,y,exm,exM,eym,eyM,Sexm,SexM,Seym,SeyM;
    x = find(format == "x");
    y = find(format == "y");
    exm = find(format == "-dx");
    exM = find(format == "+dx");
    Sexm = find(format == "-sx");
    SexM = find(format == "+sx");
    eym = find(format == "-dy");
    eyM = find(format == "+dy");
    Seym = find(format == "-sy");
    SeyM = find(format == "+sy");

    real[] xpoints;
    if (x == -1) { // We dont have an x column
      int n = fd;
      real xmin = fd;
      real xmax = fd;
      xpoints = uniform(xmin,xmax,n);
    }

    // Read data
    real[][] data = fd.dimension(0,format.length);
    data = transpose(data);
    close(fd);

    if (format.length != data.length)
      abort("Error reading data file.");

    // Create empty arrays for non existent columns and append x column
    if (x == -1) { x = data.length; data.push(xpoints); }
    if (y == -1) { y = data.length; data.push(new real[]); }
    if (exm == -1) { exm = data.length; data.push(new real[]); }
    if (exM == -1) { exM = data.length; data.push(data[exm]); }
    if (Sexm == -1) { Sexm = data.length; data.push(new real[]); }
    if (SexM == -1) { SexM = data.length; data.push(data[Sexm]); }
    if (eym == -1) { eym = data.length; data.push(new real[]); }
    if (eyM == -1) { eyM = data.length; data.push(data[eym]); }
    if (Seym == -1) { Seym = data.length; data.push(new real[]); }
    if (SeyM == -1) { SeyM = data.length; data.push(data[Seym]); }

    operator init(name,cite,data[x],data[y],data[exm],data[exM],data[eym],data[eyM],
                                  data[Sexm],data[SexM],data[Seym],data[SeyM]);
  }

  private void readROOT(string file, string name, int version)
  {
    string command = "rootasy " + file + " get " + name + "," + string(version);
    string binfile = file + "-" + replace(name,"/","-") + "," + string(version) + ".bin";

    system(command);

    // Read data
    file fd = input(binfile,mode="xdr");
    int N = fd;
    real[][] data = new real[][];
    for (int i = 0; i < N; ++i)
      data.push(fd.read(1));
    close(fd);
    delete(binfile);

    // Construct arrays
    real[] x,y,exm,exM,eym,eyM;
    x = data[0];
    y = data[1];
    if (N == 3) { // TH1
      eym = data[2];
      eyM = eym;
      for (int i = 0; i < x.length-1; ++i)
        exm.push(0.5*(x[i]-x[i+1]));
      exM = exm;
    }
    else if (N == 4) { // TGraphErrors
      exm = data[2];
      exM = exm;
      eym = data[3];
      eyM = eym;
    }
    else if (N == 6) { // TGraphAsymmErrors
      exm = data[2];
      exM = data[3];
      eym = data[4];
      eyM = data[5];
    }

    real[] e;
    operator init(x,y,exm,exM,eym,eyM,e,e,e,e);
  }

  void operator init(string filename, int version = -1, string formats = "")
  {
    bool3 isroot = default;
    if (version != -1) isroot = true;
    else if (formats != "") isroot = false;

    if (isroot == default) {
      file fd = input(filename,false);
      isroot = error(fd);
      close(fd);
    }

    if (isroot) {
      string[] partname = split(filename,",");
      string name = partname.pop();
      string file;
      for (string s : partname) file += s;
      readROOT(file,name,version == -1 ? 9999 : version);
    }
    else {
      readTXT(filename,formats,formats == "");
    }
  }
  //}}}
  // {{{3 Object Manipulation
  void add(real c)
  { this.y = map(new real (real x) { return c+x; }, this.y); }

  real sum()
  {
    real S = 0.0;
    for (int i = 1; i < y.length-1; ++i)
      S += y[i];
    return S;
  }

  void multiply(real c)
  {
    this.y = map(new real (real x) { return c*x; }, this.y);
    this.stat.y = map(new real (real x) { return c*x; }, this.stat.y);
    this.stat.Y = map(new real (real x) { return c*x; }, this.stat.Y);
  }

  real integral()
  {
    real I = 0.0;
    for (int i = 1; i < y.length-1; ++i)
      I += y[i]*(x[i+1]-x[i]);
    return I;
  }

  void normalize()
  {
    this.multiply(1/this.integral());
  }

  void setRange(bool3 condfunc(real,real,real,real,real,real,real,real,real,real))
  {
    for (int i = 0; i < this.cond.length; ++i)
      this.cond[i] = condfunc(this.getXcenter()[i],this.y[i],
        this.stat.x[i],this.stat.X[i],this.stat.y[i],this.stat.Y[i],
        this.syst.x[i],this.syst.X[i],this.syst.y[i],this.syst.Y[i]);
  }

  void setRange(pair min = (-inf,-inf), pair max = (inf,inf))
  {
    bool3 condfunc(real x, real y, real, real, real, real, real, real, real, real)
    {
      if (min.x <= x && x <= max.x && min.y <= y && y <= max.y) return true;
      return false;
    }
    this.setRange(condfunc);
  }

  void setRange(real min, real max)
  {
    bool3 condfunc(real x, real, real, real, real, real, real, real, real, real)
    {
      if (min <= x && x <= max) return true;
      return false;
    }
    this.setRange(condfunc);
  }

  void setOverflow(bool3 overflow=true)
  {
    this.cond[0] = overflow;
    this.cond[this.cond.length-1] = overflow;
  }

  void rebin(int n)
  {
    real[] x, y;
    error syst, stat;
    int size = 0;
    bool3[] cond;

    x.push(this.x[0]);
    y.push(this.y[0]);
    syst.x.push(0);
    syst.y.push(0);
    syst.X.push(0);
    syst.Y.push(0);
    stat.x.push(0);
    stat.y.push(0);
    stat.X.push(0);
    stat.Y.push(0);
    cond.push(false);
    ++size;
    int n0 = this.x.length;
    for (int i = 1; i < n0; i += n) {
      x.push(this.x[i]);
      y.push(average(this.y[i:i+n]));
      syst.x.push(0);
      syst.y.push(0);
      syst.X.push(0);
      syst.Y.push(0);
      stat.x.push(0);
      stat.y.push(0);
      stat.X.push(0);
      stat.Y.push(0);
      cond.push(true);
      ++size;
    }

    this.x = x[:];
    this.y = y[:];
    this.syst.x = syst.x[:];
    this.syst.X = syst.X[:];
    this.syst.y = syst.y[:];
    this.syst.Y = syst.Y[:];
    this.stat.x = stat.x[:];
    this.stat.X = stat.X[:];
    this.stat.y = stat.y[:];
    this.stat.Y = stat.Y[:];
    this.cond = cond[:];
    this.size = size;
  }
  //}}}
  // {{{3 Drawing routines
  guide[] graph(picture pic=currentpicture, interpolate join=operator --)
  { return graph_safelog(pic,this.getXcenter(),this.y,this.cond,join); }

  void errorbars(picture pic=currentpicture, pen p=currentpen, real size=barscale)
  { errorbars_safelog(pic,this.getXcenter(),this.y,this.stat.X,this.stat.Y,this.stat.x,this.stat.y,this.cond,p,linewidth(p)*size); }
  void errorbarsX(picture pic=currentpicture, pen p=currentpen, real size=barscale)
  { errorbars_safelog(pic,this.getXcenter(),this.y,this.stat.X,array(this.size,0),this.stat.x,array(this.size,0),this.cond,p,linewidth(p)*size); }
  void errorbarsY(picture pic=currentpicture, pen p=currentpen, real size=barscale)
  { errorbars_safelog(pic,this.getXcenter(),this.y,array(this.size,0),this.stat.Y,array(this.size,0),this.stat.y,this.cond,p,linewidth(p)*size); }

  void errorblocks(picture pic=currentpicture, pen p=currentpen, real size=barscale)
  { errorblocks_safelog(pic,this.getXcenter(),this.y,this.syst.X,this.syst.Y,this.syst.x,this.syst.y,this.cond,p,linewidth(p)*size); }
  void errorblocksX(picture pic=currentpicture, pen p=currentpen, real size=barscale)
  { errorblocks_safelog(pic,this.getXcenter(),this.y,this.syst.X,array(this.size,0),this.syst.x,array(this.size,0),this.cond,p,linewidth(p)*size); }
  void errorblocksY(picture pic=currentpicture, pen p=currentpen, real size=barscale)
  { errorblocks_safelog(pic,this.getXcenter(),this.y,array(this.size,0),this.syst.Y,array(this.size,0),this.syst.y,this.cond,p,linewidth(p)*size); }

  void errorrange(picture pic=currentpicture, pen fill=currentpen, pen border=fill)
  { errorrange_safelog(pic,this.getXcenter(),this.y,this.stat.Y,this.stat.y,this.cond,fill,border); }

  void histogram(picture pic=currentpicture, real low=-infinity,
    pen fillpen=nullpen, pen drawpen=nullpen, bool bars=false,
    Label legend="", real markersize=legendmarkersize)
  {
    if (this.x.length == this.y.length)
      abort("The object is not a histogram");
    real[] y = this.y[:];
    for (int i = 0; i < y.length; ++i)
      if(!this.cond[i]) y[i] = 0;
    histogram(pic,this.x,y,low,fillpen,drawpen,bars,legend,markersize);
  }
  //}}}
} //}}} TH1 struct
// {{{2 TH2 struct
struct TH2 {
  //{{{3 Members
  private pair[] limits;        // domain limits without overflow
  private pair[] full_limits;   // domain limits including overflow
  private bool overflow;        // whether to use overflow or not
  private real[][] data;        // actual data
  private real[][] error;       // errors for data
  private real[] x;             // x axis bins
  private real[] y;             // y axis bins
  //}}}
  //{{{3 Private functions
  //{{{4  int getXidx(real x)
  // find xbin for a given x value
  private int getXidx(real x)
  {
    int n = this.x.length-2;
    int i = search(this.x,x);
    if (this.overflow) {
      if (i < 0) return 0;
      if (i > this.x.length-2) return this.x.length-2;
    }
    else {
      if (i < 1) return 1;
      if (i > this.x.length-3) return this.x.length-3;
    }
    return i;
  }
  //}}}4
  //{{{4  int getYidx(real y)
  // find ybin for a given y value
  private int getYidx(real y)
  {
    int n = this.y.length-2;
    int i = search(this.y,y);
    if (this.overflow) {
      if (i < 0) return 0;
      if (i > this.y.length-2) return this.y.length-2;
    }
    else {
      if (i < 1) return 1;
      if (i > this.y.length-3) return this.y.length-3;
    }
    return i;
  }
  //}}}4
  //{{{4 pair[] findLimits(picture pic, pair initial, pair final)
  // returns the domain limits of the function (on the yz plane)
  private pair[] findLimits(picture pic, pair initial, pair final)
  {
    bool logx = pic.scale.x.scale.logarithmic;
    bool logy = pic.scale.y.scale.logarithmic;
    real xmin,xmax,ymin,ymax;
    xmin = initial.x;
    xmax = final.x;
    ymin = initial.y;
    ymax = final.y;

    if (xmin == -inf) {
      if (logx) {
        int i = search(this.x,0) + 1;
        if (!this.overflow && i == 0) ++i;
        xmin = this.x[i];
      }
      else xmin = this.overflow ? this.full_limits[0].x : this.limits[0].x;
    }
    if (ymin == -inf) {
      if (logy) {
        int j = search(this.y,0) + 1;
        if (!this.overflow && j == 0) ++j;
        ymin = this.y[j];
      }
      else ymin = this.overflow ? this.full_limits[0].y : this.limits[0].y;
    }
    if (xmax == inf) xmax = this.overflow ? this.full_limits[1].x : this.limits[1].x;
    if (ymax == inf) ymax = this.overflow ? this.full_limits[1].y : this.limits[1].y;

    return new pair[] {(xmin,ymin),(xmax,ymax)};
  }
  //}}}4
  //{{{4 real pMax(bool reset = false)
  // returns the maximum value of the matrix, the first call evaluates the
  // maximum and saves it in a static variable. If true is passed to the
  // function it forces next execution to perform a new calculation.
  private real pMax(bool reset = false)
  {
    static bool done = false;
    static real max = 0.0;

    if (reset) {
      done = false;
      return max;
    }
    if (done) return max;
    done = true;

    if (this.overflow)
      max = max(this.data);
    else {
      max = -inf;
      for (int i = 1; i < this.data.length-1; ++i) {
        int n = this.data[0].length;
        max = max(max,max(this.data[i][1:n-1]));
      }
    }

    return max;
  }
  //}}}4
  //{{{4 real pMin(bool reset = false)
  // returns the minimum value of the matrix, the first call evaluates the
  // minimum and saves it in a static variable. If true is passed to the
  // function it forces next execution to perform a new calculation.
  private real pMin(bool reset = false)
  {
    static bool done = false;
    static real min = 0.0;

    if (reset) {
      done = false;
      return min;
    }
    if (done) return min;
    done = true;

    if (this.overflow)
      min = min(this.data);
    else {
      min = inf;
      for (int i = 1; i < this.data.length-1; ++i) {
        int n = this.data[0].length;
        min = min(min,min(this.data[i][1:n-1]));
      }
    }

    return min;
  }
  //}}}4
  //{{{4 real pMinPos(bool reset = false)
  // returns the minimum positive value of the matrix, the first call
  // evaluates the maximum and saves it in a static variable. If true is
  // passed to the function it forces next execution to perform a new
  // calculation.
  private real pMinPos(bool reset = false)
  {
    static real min = inf;
    static bool done = false;

    if (reset) {
      done = false;
      return min;
    }
    if (done) return min;
    done = true;

    min = inf;
    int a = 0, b = 0;
    int nx = this.data.length;
    int ny = this.data[0].length;
    if (this.overflow) {
      a = b = 1;
      --nx; --ny;
    }

    for (int i = a; i < nx; ++i)
      for (int j = b; j < ny; ++j)
        if (this.data[i][j] > 0 && this.data[i][j] < min)
          min = this.data[i][j];

    return min;
  }
  //}}}4
  //{{{4 void reset()
  // resets every method that saves static variables
  private void reset()
  {
    pMax(true);
    pMin(true);
    pMinPos(true);
  }
  //}}}4
  //}}}3
  //{{{3 Public function
  //{{{4 int[] slicesX()
  // Returns an array of the sequence of slices along x axis
  int[] slicesX()
  {
    if (this.overflow) return sequence(this.y.length-1);
    return sequence(1,this.y.length-3);
  }
  //}}}4
  //{{{4 real slicesXValues(int i)
  // Returns the value of the slice i in x axis
  real slicesXValues(int i)
  { return 0.5*(this.y[i] + this.y[i+1]); }
  //}}}4
  //{{{4 int[] slicesY()
  // Returns an array of the sequence of slices along y axis
  int[] slicesY()
  {
    if (this.overflow) return sequence(this.x.length-1);
    return sequence(1,this.x.length-3);
  }
  //}}}4
  //{{{4 real slicesYValues(int i)
  // Returns the value of the slice i in y axis
  real slicesYValues(int i)
  { return 0.5*(this.x[i] + this.x[i+1]); }
  //}}}4
  //{{{4 real eval(real x, real y)
  // Evaluates the matrix bin corresponding to (x,y)
  real eval(real x, real y)
  {
    int i = getXidx(x);
    int j = getYidx(y);
    return this.data[i][j];
  }
  //}}}
  //{{{4 pair lowerBound()
  // returns (xmin,ymin)
  pair lowerBound()
  {
    if (this.overflow)
      return full_limits[0];
    else
      return limits[0];
  }
  //}}}4
  //{{{4 pair upperBound()
  // returns (xmax,ymax)
  pair upperBound()
  {
    if (this.overflow)
      return full_limits[1];
    else
      return limits[1];
  }
  //}}}4
  //{{{4 real min(bool positive = false)
  // returns the minimum value of the matrix in the current domain. If
  // positive is true then it returns the minimum value that is greater than
  // zero.
  real min(bool positive = false) { return positive ? pMinPos() : pMin(); }
  //}}}4
  //{{{4 real max()
  // returns the maximum value of the matrix in the current domain.
  real max() { return pMax(); }
  //}}}4
  //{{{4 add(real x)
  // Adds a constant 'x' to every cell of the object
  void add(real x)
  {
    for (int i = 0; i < this.data.length; ++i)
      this.data[i] += x;
    reset();
  }
  //}}}4
  //{{{4 multiply(real x)
  // Multiplies each cell of the object by a constant 'x'
  void multiply(real x)
  {
    for (int i = 0; i < this.data.length; ++i) {
      this.data[i] *= x;
      this.error[i] *= abs(x);
    }
    reset();
  }
  //}}}4
  //{{{4 setOverflow(bool overflow = true)
  // Sets visibility of overflow bins
  void setOverflow(bool overflow = true) { this.overflow = overflow; reset(); }
  //}}}4
  //{{{4 transpose()
  // transpose the object
  void transpose()
  {
    this.data = transpose(this.data);
    this.error = transpose(this.error);
    this.limits = swap*this.limits;
    this.full_limits = swap*this.full_limits;
    real[] aux = this.x;
    this.x = this.y;
    this.y = aux;

  }
  //}}}
  //{{{4 TH1 projectionX(real ymin, real ymax=ymin)
  // projects from ymin to ymax creating a TH1 object along x axis.
  TH1 projectionX(real ymin, real ymax=ymin)
  {
    int a = getYidx(ymin);
    int b = getYidx(ymax)+1;

    real[] x = this.x;
    real[] y,e;

    for (int i = 0; i < x.length-1; ++i) {
      y.push(sum(data[i][a:b]));
      e.push(sqrt(sum(map(new real(real x) { return x^2; }, error[i][a:b]))));
    }

    return TH1(x,y,eym=e,eyM=e);
  }
  //}}}4
  //{{{4 TH1 projectionY(real xmin, real xmax=xmin)
  // projects from xmin to xmax creating a TH1 object along y axis.
  TH1 projectionY(real xmin, real xmax=xmin)
  {
    int a = getXidx(xmin);
    int b = getXidx(xmax)+1;

    real[] x = this.y;
    real[] y,e;

    real[][] data = transpose(this.data[a:b]);
    real[][] error = transpose(this.error[a:b]);
    for (int j = 0; j < x.length-1; ++j) {
      y.push(sum(data[j]));
      e.push(sqrt(sum(map(new real(real x) { return x^2; },error[j]))));
    }

    return TH1(x,y,eym=e,eyM=e);
  }
  //}}}4
  //{{{4 TH1 sliceX(int i)
  // projects slice 'i' along x axis.
  TH1 sliceX(int i)
  {
    real y = this.y[i];
    return this.projectionX(y);
  }
  //}}}4
  //{{{4 TH1 sliceY(int i)
  // projects slice 'i' along y axis.
  TH1 sliceY(int i)
  {
    real x = this.x[i];
    return this.projectionY(x);
  }
  //}}}4
  //{{{4 TH1 curve(real x = inf, real y = inf, real f(real t) = null)
  TH1 curve(real x = inf, real y = inf, real f(real t) = null)
  {
    real[] xaxis,yaxis,error;

    if (finite(y)) {
      if (finite(x) || f != null)
        abort("You must specify only one of 'x=c', 'y=c' or 'real f(real)'...");

      xaxis = this.x;
      int ybin = getYidx(y);
      for (int i = 0; i < xaxis.length-1; ++i) {
        yaxis.push(this.data[i][ybin]);
        error.push(this.error[i][ybin]);
      }
    }
    else if (finite(x)) {
      if (f != null)
        abort("You must specify only one of 'x=c', 'y=c' or 'real f(real)'...");

      xaxis = this.y;
      int xbin = getXidx(x);
      for (int j = 0; j < xaxis.length-1; ++j) {
        yaxis.push(this.data[xbin][j]);
        error.push(this.error[xbin][j]);
      }
    }
    else {
      xaxis = this.x;
      for (int i = 0; i < xaxis.length-1; ++i) {
        yaxis.push(this.data[i][getYidx(f(xaxis[i]))]);
        error.push(this.error[i][getYidx(f(xaxis[i]))]);
      }
    }

    return TH1(xaxis,yaxis,eym=error,eyM=error);
  }
  //}}}4
  //}}}3
  //{{{3 Contructors
  //{{{4 init(real[] x, real[] y, real[][] data, real[][] e)
  // initializes the struct with x and y bins arrays, the data and errors
  void operator init (real[] x, real[] y, real[][] data, real[][] e)
  {
    if (data.length != x.length-1 || data[0].length != y.length-1)
      abort("Error initializing TH2 struct.");

    int nx = x.length-1;
    int ny = y.length-1;
    this.x = x[:];
    this.y = y[:];
    this.data = copy(data);
    if (e.length == 0)
      for (int i = 0; i < nx; ++i)
        e.push(array(ny,0));
    this.error = copy(e);
    this.overflow = false;
    this.full_limits = new pair[] {(x[0],y[0]), (x[nx],y[ny])};
    this.limits = new pair[] {(x[1],y[1]), (x[nx-1],y[ny-1])};
  }
  //}}}4
  //{{{4 readROOT(string file, string name, int version = 9999)
  // construct TH2 from an object 'name' within a root file. Version is the
  // root version of the object.
  private void readROOT(string file, string name, int version = 9999)
  {
    string command = "rootasy " + file + " get " + name + "," + string(version);
    string binfile = file + "-" + replace(name,"/","-") + "," + string(version) + ".bin";

    system(command);

    // Read data
    file fd = input(binfile,mode="xdr");
    real[] x = fd.read(1);
    real[] y = fd.read(1);
    int nx = x.length-1;
    int ny = y.length-1;
    real[][] data = fd.dimension(nx,ny);
    real[][] error = fd.dimension(nx,ny);
    close(fd);
    delete(binfile);

    operator init(x,y,data,error);
  }
  //}}}4
  //{{{4 init(string filename, int version = -1)
  // Constructor from external file, if version != -1 it forces a root file,
  // otherwise, tries to open 'filename' as is and if succeeded treat it as
  // txt file, if not treat it as root file and object names.
  void operator init(string filename, int version = -1)
  {
    string[] partname = split(filename,",");
    string name = partname.pop();
    string file;
    for (string s : partname) file += s;
    readROOT(file,name,version == -1 ? 9999 : version);
  }
  //}}}4
  //}}}3
  //{{{3 Drawing routines
  //{{{4 bounds image(picture pic = currentpicture, range range = Full, int nx = ngraph, int ny = nx, pair initial = (-inf,-inf), pair final = (inf,inf), pen[] palette, bool antialias = false)
  // Draws a colorspace 2D image representing the object with
  // given domain (initial,final), color palette, sampling (nx,ny) and the
  // range to fit the palette.
  bounds image(picture pic = currentpicture, range range = Full,
               int nx = ngraph, int ny = nx,
               pair initial = (-inf,-inf), pair final = (inf,inf),
               pen[] palette, bool antialias = false)
  {
    bool logz = pic.scale.z.scale.logarithmic;
    real min = 1e-7 * this.min(logz);
    if (min == inf) min = 1;
    pair[] limits = findLimits(pic,initial,final);
    return image_safelog(pic,this.eval,range,limits[0],limits[1],nx,ny,palette,antialias,min);
  }
  //}}}4
  //{{{4 guide[][] contour(picture pic=currentpicture, real[] c, int nx=ngraph, int ny=nx, pair initial = (-inf,-inf), pair final = (inf,inf), interpolate join=operator --)
  // Returns contour lines on the object for values 'c'
  guide[][] contour(picture pic=currentpicture, real[] c, int nx=ngraph, int ny=nx, pair initial = (-inf,-inf), pair final = (inf,inf), interpolate join=operator --)
  {
    pair[] limits = findLimits(pic,initial,final);
    return contour(pic,this.eval,limits[0],limits[1],c,nx,ny,join);
  }
  //}}}4
  //{{{4 surface surface(picture pic=currentpicture, range range = Full, int nx=100, int ny=nx, pair initial = (-inf,-inf), pair final = (inf,inf), pen[] palette, bool spline = true)
  // Returns a painted surface representing the object, the
  // color palette is fitted to range and the surface is drawn for a given
  // domain (initial,final) and a given sampling (nx,ny).
  //surface surface(picture pic=currentpicture, range range = Full,
  //                int nx=100, int ny=nx,
  //                pair initial = (-inf,-inf), pair final = (inf,inf),
  //                pen[] palette, bool spline = true)
  //{
  //  pair[] limits = findLimits(pic,initial,final);
  //  surface s = surface_safelog_matrix(pic,this.eval,limits[0],limits[1],nx,ny,spline);

  //  if (range == Full || range == Automatic)
  //    paint_surface(s,palette);
  //  else {
  //    real min = this.min(pic.scale.z.scale.logarithmic);
  //    real max = this.max();
  //    bounds bounds = range(pic,min,max);
  //    paint_surface(s,palette,(ScaleZ(pic,bounds.min),ScaleZ(pic,bounds.max)));
  //    zlimits(bounds.min,bounds.max);
  //  }

  //  return s;
  //}
  //}}}4
  //}}}3 Drawing routines
} //}}} TH2 struct
// {{{2 TH3 struct
struct TH3 {
  //{{{3 Members
  private triple[] limits;      // domain limits without overflow
  private triple[] full_limits; // domain limits including overflow
  private bool overflow;        // whether to use overflow or not
  private real[][][] data;      // actual data
  private real[][][] error;     // errors for data
  private real[] x;             // x axis bins
  private real[] y;             // y axis bins
  private real[] z;             // z axis bins
  //}}}
  //{{{3 Private functions
  //{{{4  int getXidx(real x)
  // find xbin for a given x value
  private int getXidx(real x)
  {
    int n = this.x.length-2;
    int i = search(this.x,x);
    if (this.overflow) {
      if (i < 0) return 0;
      if (i > this.x.length-2) return this.x.length-2;
    }
    else {
      if (i < 1) return 1;
      if (i > this.x.length-3) return this.x.length-3;
    }
    return i;
  }
  //}}}4
  //{{{4  int getYidx(real y)
  // find ybin for a given y value
  private int getYidx(real y)
  {
    int n = this.y.length-2;
    int i = search(this.y,y);
    if (this.overflow) {
      if (i < 0) return 0;
      if (i > this.y.length-2) return this.y.length-2;
    }
    else {
      if (i < 1) return 1;
      if (i > this.y.length-3) return this.y.length-3;
    }
    return i;
  }
  //}}}4
  //{{{4  int getZidx(real z)
  // find zbin for a given z value
  private int getZidx(real z)
  {
    int n = this.z.length-2;
    int i = search(this.z,z);
    if (this.overflow) {
      if (i < 0) return 0;
      if (i > this.z.length-2) return this.z.length-2;
    }
    else {
      if (i < 1) return 1;
      if (i > this.z.length-3) return this.z.length-3;
    }
    return i;
  }
  //}}}4
  //{{{4 function evalslice(int i)
  // returns a function f(y,z) which evals the matrix at the zbin=k
  typedef real function(real,real);
  private function evalslice(int k)
  {
    return new real(real x, real y) {
      int i = getXidx(x);
      int j = getYidx(y);
      return this.data[i][j][k];
    };
  }
  //}}}4
  //{{{4 pair[] findLimits(picture pic, pair initial, pair final)
  // returns the domain limits of the function (on the yz plane)
  private pair[] findLimits(picture pic, pair initial, pair final)
  {
    bool logx = pic.scale.x.scale.logarithmic;
    bool logy = pic.scale.y.scale.logarithmic;
    real xmin,xmax,ymin,ymax;
    xmin = initial.x;
    xmax = final.x;
    ymin = initial.y;
    ymax = final.y;

    if (xmin == -inf) {
      if (logx) {
        int i = search(this.x,0) + 1;
        if (!this.overflow && i == 0) ++i;
        xmin = this.x[i];
      }
      else xmin = this.overflow ? this.full_limits[0].x : this.limits[0].x;
    }
    if (ymin == -inf) {
      if (logy) {
        int j = search(this.y,0) + 1;
        if (!this.overflow && j == 0) ++j;
        ymin = this.y[j];
      }
      else ymin = this.overflow ? this.full_limits[0].y : this.limits[0].y;
    }
    if (xmax == inf) xmax = this.overflow ? this.full_limits[1].x : this.limits[1].x;
    if (ymax == inf) ymax = this.overflow ? this.full_limits[1].y : this.limits[1].y;

    return new pair[] {(xmin,ymin),(xmax,ymax)};
  }
  //}}}4
  //{{{4 real pMax(bool reset = false)
  // returns the maximum value of the matrix, the first call evaluates the
  // maximum and saves it in a static variable. If true is passed to the
  // function it forces next execution to perform a new calculation.
  private real pMax(bool reset = false)
  {
    static bool done = false;
    static real max = 0.0;

    if (reset) {
      done = false;
      return max;
    }
    if (done) return max;
    done = true;

    if (this.overflow)
      max = max(this.data);
    else {
      max = -inf;
      for (int i = 1; i < this.data.length-1; ++i)
        for (int j = 1; j < this.data[0].length-1; ++j) {
          int n = this.data[0][0].length;
          max = max(max,max(this.data[i][j][1:n-1]));
        }
    }

    return max;
  }
  //}}}4
  //{{{4 real pMin(bool reset = false)
  // returns the minimum value of the matrix, the first call evaluates the
  // minimum and saves it in a static variable. If true is passed to the
  // function it forces next execution to perform a new calculation.
  private real pMin(bool reset = false)
  {
    static bool done = false;
    static real min = 0.0;

    if (reset) {
      done = false;
      return min;
    }
    if (done) return min;
    done = true;

    if (this.overflow)
      min = min(this.data);
    else {
      min = inf;
      for (int i = 1; i < this.data.length-1; ++i)
        for (int j = 1; j < this.data[0].length-1; ++j) {
          int n = this.data[0][0].length;
          min = min(min,min(this.data[i][j][1:n-1]));
        }
    }

    return min;
  }
  //}}}4
  //{{{4 real pMinPos(bool reset = false)
  // returns the minimum positive value of the matrix, the first call
  // evaluates the maximum and saves it in a static variable. If true is
  // passed to the function it forces next execution to perform a new
  // calculation.
  private real pMinPos(bool reset = false)
  {
    static real min = inf;
    static bool done = false;

    if (reset) {
      done = false;
      return min;
    }
    if (done) return min;
    done = true;

    min = inf;
    int a = 0, b = 0, c = 0;
    int nx = this.data.length;
    int ny = this.data[0].length;
    int nz = this.data[0][0].length;
    if (this.overflow) {
      a = b = c = 1;
      --nx; --ny; --nz;
    }

    for (int i = a; i < nx; ++i)
      for (int j = b; j < ny; ++j)
        for (int k = c; k < nz; ++k) {
          if (this.data[i][j][k] > 0 && this.data[i][j][k] < min)
            min = this.data[i][j][k];
        }

    return min;
  }
  //}}}4
  //{{{4 void reset()
  // resets every method that saves static variables
  private void reset()
  {
    pMax(true);
    pMin(true);
    pMinPos(true);
  }
  //}}}4
  //}}}3
  //{{{3 Public function
  //{{{4 int[] slices()
  // Returns an array of the sequence of slices in z axis
  int[] slices()
  {
    if (this.overflow) return sequence(this.z.length-1);
    return sequence(1,this.z.length-3);
  }
  //}}}4
  //{{{4 real slicesValues(int i)
  // Returns the value of the slice i in z axis
  real slicesValues(int i)
  { return 0.5*(this.z[i] + this.z[i+1]); }
  //}}}4
  //{{{4 real eval(real x, real y, real z)
  // Evaluates the matrix bin corresponding to (x,y,z)
  real eval(real x, real y, real z)
  {
    int i = getXidx(x);
    int j = getYidx(y);
    int k = getZidx(z);
    return this.data[i][j][k];
  }
  //}}}
  //{{{4 triple lowerBound()
  // returns (xmin,ymin,zmin)
  triple lowerBound()
  {
    if (this.overflow)
      return full_limits[0];
    else
      return limits[0];
  }
  //}}}4
  //{{{4 triple upperBound()
  // returns (xmax,ymax,zmax)
  triple upperBound()
  {
    if (this.overflow)
      return full_limits[1];
    else
      return limits[1];
  }
  //}}}4
  //{{{4 real min(bool positive = false)
  // returns the minimum value of the matrix in the current domain. If
  // positive is true then it returns the minimum value that is greater than
  // zero.
  real min(bool positive = false) { return positive ? pMinPos() : pMin(); }
  //}}}4
  //{{{4 real max()
  // returns the maximum value of the matrix in the current domain.
  real max() { return pMax(); }
  //}}}4
  //{{{4 add(real x)
  // Adds a constant 'x' to every cell of the object
  void add(real x)
  {
    for (int i = 0; i < this.data.length; ++i)
      for (int j = 0; j < this.data[0].length; ++j)
        this.data[i][j] += x;
    reset();
  }
  //}}}4
  //{{{4 multiply(real x)
  // Multiplies each cell of the object by a constant 'x'
  void multiply(real x)
  {
    for (int i = 0; i < this.data.length; ++i)
      for (int j = 0; j < this.data[0].length; ++j) {
        this.data[i][j] *= x;
        this.error[i][j] *= abs(x);
      }
    reset();
  }
  //}}}4
  //{{{4 setOverflow(bool overflow = true)
  // Sets visibility of overflow bins
  void setOverflow(bool overflow = true) { this.overflow = overflow; reset(); }
  //}}}4
  //{{{4 transpose(... int[] perm)
  // transpose the object using perm as the new order of axis.
  void transpose(... int[] perm)
  {
    this.data = transpose(this.data,perm);
    this.error = transpose(this.error,perm);
    transform3 permute = permute(perm);
    this.limits = permute*this.limits;
    this.full_limits = permute*this.full_limits;

    real[][] axis = new real[3][];
    for (int i = 0; i < 3; ++i) {
      if (perm[i] == 0) axis[i] = this.x;
      else if (perm[i] == 1) axis[i] = this.y;
      else axis[i] = this.z;
    }
    this.x = axis[0];
    this.y = axis[1];
    this.z = axis[2];
  }
  //}}}
  //{{{4 TH2 projection(real min, real max)
  // projects from zbin(min) to zbin(max) creating a TH2 object
  TH2 projection(real min, real max=min)
  {
    int a = getZidx(min);
    int b = getZidx(max)+1;

    real[] x = this.x;
    real[] y = this.y;

    real[][] z = new real[x.length-1][y.length-1];
    real[][] e = new real[x.length-1][y.length-1];
    for (int i = 0; i < x.length-1; ++i)
      for (int j = 0; j < y.length-1; ++j) {
        z[i][j] = sum(data[i][j][a:b]);
        e[i][j] = sqrt(sum(map(new real(real x) {return x^2;}, error[i][j][a:b])));
      }
    return TH2(x,y,z,e);
  }
  //}}}4
  //{{{4 TH1 curve(int slice, real x = inf, real y = inf, real f(real t) = null)
  TH1 curve(int slice, real x = inf, real y = inf, real f(real t) = null)
  {
    real[] xaxis,yaxis,error;

    if (finite(y)) {
      if (finite(x) || f != null)
        abort("You must specify only one of 'x=c', 'y=c' or 'real f(real)'...");

      xaxis = this.x;
      int ybin = getYidx(y);
      for (int i = 0; i < xaxis.length-1; ++i) {
        yaxis.push(this.data[i][ybin][slice]);
        error.push(this.error[i][ybin][slice]);
      }
    }
    else if (finite(x)) {
      if (f != null)
        abort("You must specify only one of 'x=c', 'y=c' or 'real f(real)'...");

      xaxis = this.y;
      int xbin = getXidx(x);
      for (int j = 0; j < xaxis.length-1; ++j) {
        yaxis.push(this.data[xbin][j][slice]);
        error.push(this.error[xbin][j][slice]);
      }
    }
    else {
      xaxis = this.x;
      for (int i = 0; i < xaxis.length-1; ++i) {
        yaxis.push(this.data[i][getYidx(f(xaxis[i]))][slice]);
        error.push(this.error[i][getYidx(f(xaxis[i]))][slice]);
      }
    }

    return TH1(xaxis,yaxis,eym=error,eyM=error);
  }
  //}}}4
  //}}}3
  //{{{3 Contructors
  //{{{4 init(real[] x, real[] y, real[] z, real[][][] data, real[][][] e)
  // initializes the struct with x, y and z bins arrays, the data and errors
  void operator init (real[] x, real[] y, real[] z, real[][][] data, real[][][] e)
  {
    if (data.length != x.length-1 || data[0].length != y.length-1 || data[0][0].length != z.length-1)
      abort("Error initializing TH2 struct.");

    int nx = x.length-1;
    int ny = y.length-1;
    int nz = z.length-1;
    this.x = x[:];
    this.y = y[:];
    this.z = z[:];
    this.data = copy(data);
    if (e.length == 0)
      for (int i = 0; i < nx; ++i)
        e.push(array(ny,array(nz,0)));
    this.error = copy(e);
    this.overflow = false;
    this.full_limits = new triple[] {(x[0],y[0],z[0]), (x[nx],y[ny],z[nz])};
    this.limits = new triple[] {(x[1],y[1],z[1]), (x[nx-1],y[ny-1],z[nz-1])};
  }
  //}}}4
  //{{{4 readROOT(string file, string name, int version = 9999)
  // construct TH3 from an object 'name' within a root file. Version is the
  // root version of the object.
  private void readROOT(string file, string name, int version = 9999)
  {
    string command = "rootasy " + file + " get " + name + "," + string(version);
    string binfile = file + "-" + replace(name,"/","-") + "," + string(version) + ".bin";

    system(command);

    // Read data
    file fd = input(binfile,mode="xdr");
    real[] x = fd.read(1);
    real[] y = fd.read(1);
    real[] z = fd.read(1);
    int nx = x.length-1;
    int ny = y.length-1;
    int nz = z.length-1;
    real[][][] data = fd.dimension(nx,ny,nz);
    real[][][] error = fd.dimension(nx,ny,nz);
    close(fd);
    delete(binfile);

    operator init(x,y,z,data,error);
  }
  //}}}4
  //{{{4 init(string filename, int version = -1)
  // Constructor from external file, if version != -1 it forces a root file,
  // otherwise, tries to open 'filename' as is and if succeeded treat it as
  // txt file, if not treat it as root file and object names.
  void operator init(string filename, int version = -1)
  {
    string[] partname = split(filename,",");
    string name = partname.pop();
    string file;
    for (string s : partname) file += s;
    readROOT(file,name,version == -1 ? 9999 : version);
  }
  //}}}4
  //}}}3
  //{{{3 Drawing routines
  //{{{4 bounds image(int bin, picture pic = currentpicture, range range = Full, int nx = ngraph, int ny = nx, pair initial = (-inf,-inf), pair final = (inf,inf), pen[] palette, bool antialias = false)
  // Draws a colorspace 2D image representing the slice at zbin=bin with
  // given domain (initial,final), color palette, sampling (nx,ny) and the
  // range to fit the palette.
  bounds image(int bin, picture pic = currentpicture, range range = Automatic,
               int nx = ngraph, int ny = nx,
               pair initial = (-inf,-inf), pair final = (inf,inf),
               pen[] palette, bool antialias = false)
  {
    bool logz = pic.scale.z.scale.logarithmic;
    real min = this.min(logz);
    real max = this.max();
    if (range == Automatic) range = Range(min,max);
    pair[] limits = findLimits(pic,initial,final);
    return image_safelog(pic,evalslice(bin),range,limits[0],limits[1],nx,ny,palette,antialias,min);
  }
  //}}}4
  //{{{4 guide[][] contour(int bin, picture pic=currentpicture, real[] c, int nx=ngraph, int ny=nx, pair initial = (-inf,-inf), pair final = (inf,inf), interpolate join=operator --)
  // Returns contour lines on a 2D slice on zbin=bin for values 'c'
  guide[][] contour(int bin, picture pic=currentpicture, real[] c, int nx=ngraph, int ny=nx, pair initial = (-inf,-inf), pair final = (inf,inf), interpolate join=operator --)
  {
    pair[] limits = findLimits(pic,initial,final);
    return contour(pic,evalslice(bin),limits[0],limits[1],c,nx,ny,join);
  }
  //}}}4
  //{{{4 surface surface(int bin, picture pic=currentpicture, range range = Full, int nx=100, int ny=nx, pair initial = (-inf,-inf), pair final = (inf,inf), pen[] palette, bool spline = true)
  // Returns a painted surface representing a slice on the zbin=bin, the
  // color palette is fitted to range and the surface is drawn for a given
  // domain (initial,final) and a given sampling (nx,ny).
  //surface surface(int bin, picture pic=currentpicture, range range = Automatic,
  //                int nx=100, int ny=nx,
  //                pair initial = (-inf,-inf), pair final = (inf,inf),
  //                pen[] palette, bool spline = true)
  //{
  //  pair[] limits = findLimits(pic,initial,final);
  //  surface s = surface_safelog_matrix(pic,evalslice(bin),limits[0],limits[1],nx,ny,spline);

  //  if (range == Full)
  //    paint_surface(s,palette);
  //  else {
  //    real min = this.min(pic.scale.z.scale.logarithmic);
  //    real max = this.max();
  //    if (range == Automatic) range = Range(min,max);
  //    bounds bounds = range(pic,min,max);
  //    paint_surface(s,palette,(ScaleZ(pic,bounds.min),ScaleZ(pic,bounds.max)));
  //    zlimits(bounds.min,bounds.max);
  //  }

  //  return s;
  //}
  //}}}4
  //}}}3 Drawing routines
} //}}} TH3 struct
// {{{2 Operations with histograms
TH1 operator +(real c, TH1 h) { h.add(c); return h; }
TH1 operator +(TH1 h, real c) { h.add(c); return h; }
TH1 operator -(real c, TH1 h) { h.multiply(-1); h.add(c); return h; }
TH1 operator -(TH1 h, real c) { h.add(-c); return h; }
TH1 operator *(real c, TH1 h) { h.multiply(c); return h; }
TH1 operator *(TH1 h, real c) { h.multiply(c); return h; }
TH1 operator /(TH1 h, real c) { h.multiply(1/c); return h; }

TH2 operator +(real c, TH2 h) { h.add(c); return h; }
TH2 operator +(TH2 h, real c) { h.add(c); return h; }
TH2 operator -(real c, TH2 h) { h.multiply(-1); h.add(c); return h; }
TH2 operator -(TH2 h, real c) { h.add(-c); return h; }
TH2 operator *(real c, TH2 h) { h.multiply(c); return h; }
TH2 operator *(TH2 h, real c) { h.multiply(c); return h; }
TH2 operator /(TH2 h, real c) { h.multiply(1/c); return h; }

TH3 operator +(real c, TH3 h) { h.add(c); return h; }
TH3 operator +(TH3 h, real c) { h.add(c); return h; }
TH3 operator -(real c, TH3 h) { h.multiply(-1); h.add(c); return h; }
TH3 operator -(TH3 h, real c) { h.add(-c); return h; }
TH3 operator *(real c, TH3 h) { h.multiply(c); return h; }
TH3 operator *(TH3 h, real c) { h.multiply(c); return h; }
TH3 operator /(TH3 h, real c) { h.multiply(1/c); return h; }

TH1 min(... TH1[] objs)
{
  // x axis
  real[][] xs,ys;
  for (TH1 obj : objs) {
    xs.push(obj.getX());
    ys.push(obj.getY());
  }
  ys = transpose(ys);

  for (int i = 1; i < xs.length; ++i)
    if (find(xs[i] == xs[i-1]) == -1)
      abort("ERROR finding minimum: histograms differ.");

  real[] y;
  for (int i = 0; i < ys.length; ++i)
    y.push(min(ys[i]));

  return TH1(xs[0],y);
}

TH1 max(... TH1[] objs)
{
  // x axis
  real[][] xs,ys;
  for (TH1 obj : objs) {
    xs.push(obj.getX());
    ys.push(obj.getY());
  }
  ys = transpose(ys);

  for (int i = 1; i < xs.length; ++i)
    if (find(xs[i] == xs[i-1]) == -1)
      abort("ERROR finding minimum: histograms differ.");

  real[] y;
  for (int i = 0; i < ys.length; ++i)
    y.push(max(ys[i]));

  return TH1(xs[0],y);
}

TH1 operator /(TH1 h1, TH1 h0)
{
  real[] x = h0.getX();
  real[] y0 = h0.getY();
  real[] y1 = h1.getY();

  for (int i = 0; i < y0.length; ++i)
    y1[i] = (y0[i] == 0) ? 0 : y1[i] / y0[i];

  return TH1(x, y1);
}
//}}}
// {{{2 Drawings with histograms
void drawrange(TH1 h1, TH1 h2, pen fill=currentpen, pen border=fill, interpolate join=operator --)
{
  path up = h1.graph(join)[0];
  path dn = h2.graph(join)[0];
  path range = up -- reverse(dn) -- cycle;
  filldraw(range,fill,border);
}
//}}}
//}}}1
