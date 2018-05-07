// compile with: -I/usr/include/tirpc -ltirpc
#include<iostream>
#include<vector>
#include<string>

#include<TROOT.h>
#include<TFile.h>
#include<TH1.h>
#include<TH2.h>
#include<TH3.h>
#include<TGraph.h>
#include<TGraphErrors.h>
#include<TGraphAsymmErrors.h>
#include<TF1.h>
#include<TVector.h>
#include<TArray.h>
#include<TArrayL.h>
#include<TMath.h>

#include<rpc/xdr.h>

using namespace std;
const vector<string> classes = { "TH1", "TH2", "TH3", "TGraphAsymmErrors", "TGraphErrors", "TGraph", "TF1", "TVectorT<float>", "TVectorT<double>" };

// Template function to write TObjects
template <typename T> void write(T *obj, string filename)
{ std::cout << "I don't know how to deal with this type of object..." << std::endl; }

// Specializations
template <> void write<TH1> (TH1 *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  int N = 3;
  xdr_int(&xdr_data, &N);

  // Write X axis
  N = obj->GetNbinsX() + 3;
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double value = obj->GetBinLowEdge(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  N--;

  // Write Y axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double value = obj->GetBinContent(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  
  // Write errors
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double value = obj->GetBinError(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  fclose(fd);
}

template <> void write<TH2> (TH2 *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  // Write X axis
  int Nx = obj->GetNbinsX() + 3;
  xdr_int(&xdr_data, &Nx);
  for (int i = 0; i < Nx; ++i) {
    double value = obj->GetXaxis()->GetBinLowEdge(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  --Nx;

  // Write Y axis
  int Ny = obj->GetNbinsY() + 3;
  xdr_int(&xdr_data, &Ny);
  for (int i = 0; i < Ny; ++i) {
    double value = obj->GetYaxis()->GetBinLowEdge(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  --Ny;

  // Write bin contents
  for (int i = 0; i < Nx; ++i)
    for (int j = 0; j < Ny; ++j) {
      double value = obj->GetBinContent(i,j);
      if (!isfinite(value)) value = 0;
      xdr_double(&xdr_data, &value);
    }

  // Write bin errors
  for (int i = 0; i < Nx; ++i)
    for (int j = 0; j < Ny; ++j) {
      double value = obj->GetBinError(i,j);
      if (!isfinite(value)) value = 0;
      xdr_double(&xdr_data, &value);
    }

  fclose(fd);
}

template <> void write<TH3> (TH3 *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  // Write X axis
  int Nx = obj->GetNbinsX() + 3;
  xdr_int(&xdr_data, &Nx);
  for (int i = 0; i < Nx; ++i) {
    double value = obj->GetXaxis()->GetBinLowEdge(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  --Nx;

  // Write Y axis
  int Ny = obj->GetNbinsY() + 3;
  xdr_int(&xdr_data, &Ny);
  for (int i = 0; i < Ny; ++i) {
    double value = obj->GetYaxis()->GetBinLowEdge(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  --Ny;

  // Write Z axis
  int Nz = obj->GetNbinsZ() + 3;
  xdr_int(&xdr_data, &Nz);
  for (int i = 0; i < Nz; ++i) {
    double value = obj->GetZaxis()->GetBinLowEdge(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  --Nz;

  // Write bin contents
  for (int i = 0; i < Nx; ++i)
    for (int j = 0; j < Ny; ++j)
      for (int k = 0; k < Nz; ++k) {
        double value = obj->GetBinContent(i,j,k);
        if (!isfinite(value)) value = 0;
        xdr_double(&xdr_data, &value);
      }

  // Write bin errors
  for (int i = 0; i < Nx; ++i)
    for (int j = 0; j < Ny; ++j)
      for (int k = 0; k < Nz; ++k) {
        double value = obj->GetBinError(i,j,k);
        if (!isfinite(value)) value = 0;
        xdr_double(&xdr_data, &value);
      }

  fclose(fd);
}

template <> void write<TF1> (TF1 *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  int N = 2;
  xdr_int(&xdr_data, &N);

  N = 1000;
  obj->SetNpx(N);

  // Write X axis
  double xmin,xmax,dx;
  obj->GetRange(xmin,xmax);
  dx = (xmax-xmin)/(N-1);
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double x = xmin + i*dx;
    xdr_double(&xdr_data, &x);
  }

  // Write Y axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double y = obj->Eval(xmin+i*dx);
    if (!isfinite(y)) y = 0;
    xdr_double(&xdr_data, &y);
  }

  fclose(fd);
}

template <> void write<TGraph> (TGraph *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  int N = 2;
  xdr_int(&xdr_data, &N);

  N = obj->GetN();
  double *x = obj->GetX();
  double *y = obj->GetY();

  // Write X axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double xi = x[i];
    xdr_double(&xdr_data, &(xi));
  }

  // Write Y axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double yi = y[i];
    if (!isfinite(yi)) yi = 0;
    xdr_double(&xdr_data, &(yi));
  }

  fclose(fd);
}

template <> void write<TGraphErrors> (TGraphErrors *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  int N = 4;
  xdr_int(&xdr_data, &N);

  N = obj->GetN();
  double *x = obj->GetX();
  double *y = obj->GetY();
  double *ex = obj->GetEX();
  double *ey = obj->GetEY();

  // Write X axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double xi = x[i];
    xdr_double(&xdr_data, &(xi));
  }

  // Write Y axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double yi = y[i];
    if (!isfinite(yi)) yi = 0;
    xdr_double(&xdr_data, &(yi));
  }

  // Write X error
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double exi = ex[i];
    if (!isfinite(exi)) exi = 0;
    xdr_double(&xdr_data, &(exi));
  }

  // Write Y error
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double eyi = ey[i];
    if (!isfinite(eyi)) eyi = 0;
    xdr_double(&xdr_data, &(eyi));
  }

  fclose(fd);
}

template <> void write<TGraphAsymmErrors> (TGraphAsymmErrors *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  int N = 6;
  xdr_int(&xdr_data, &N);

  N = obj->GetN();
  double *x = obj->GetX();
  double *y = obj->GetY();
  double *ex = obj->GetEXlow();
  double *ey = obj->GetEYlow();
  double *Ex = obj->GetEXhigh();
  double *Ey = obj->GetEYhigh();

  // Write X axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double xi = x[i];
    xdr_double(&xdr_data, &(xi));
  }

  // Write Y axis
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double yi = y[i];
    if (!isfinite(yi)) yi = 0;
    xdr_double(&xdr_data, &(yi));
  }

  // Write X error
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double exi = ex[i];
    if (!isfinite(exi)) exi = 0;
    xdr_double(&xdr_data, &(exi));
  }
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double Exi = Ex[i];
    if (!isfinite(Exi)) Exi = 0;
    xdr_double(&xdr_data, &(Exi));
  }

  // Write Y error
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double eyi = ey[i];
    if (!isfinite(eyi)) eyi = 0;
    xdr_double(&xdr_data, &(eyi));
  }
  xdr_int(&xdr_data, &N);
  for (int i = 0; i < N; ++i) {
    double Eyi = Ey[i];
    if (!isfinite(Eyi)) Eyi = 0;
    xdr_double(&xdr_data, &(Eyi));
  }

  fclose(fd);
}

template <> void write<TArray> (TArray *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  int N = obj->GetSize();
  for (int i = 0; i < N; ++i) {
    double value = obj->GetAt(i);
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  fclose(fd);
}

template <typename T> void write(TVectorT<T> *obj, string filename)
{
  FILE *fd = fopen(filename.c_str(),"wb");
  XDR xdr_data;
  xdrstdio_create(&xdr_data, fd, XDR_ENCODE);

  int N = obj->GetNrows();
  for (int i = 0; i < N; ++i) {
    double value = (*obj)[i];
    if (!isfinite(value)) value = 0;
    xdr_double(&xdr_data, &value);
  }
  fclose(fd);
}

void listRoot(string rootfile)
{
  TFile *fd = new TFile(rootfile.c_str(),"READ");
  fd->ReadAll("dirs");
  fd->ls();
  fd->Close();
}

string formatNameCycle(string rootfile, string &obj)
{
  string outname = obj+".bin";
  size_t pos = outname.find("/");
  while (pos != string::npos) {
    outname.replace(pos,1,"-");
    pos = outname.find("/");
  }
  outname = rootfile+"-"+outname;

  // Now fix namecycle changing ',' to ';'
  // We work with ',' to create filenames and command line as ';' is
  // interpreted by shell, but actual ROOT namecycle is done with ';'.
  pos = obj.rfind(",");
  if (pos != string::npos)
    obj.replace(pos,1,";");

  return outname;
}

void getObjs(string rootfile, vector<string> objs)
{
  // Open file
  TFile *fd = new TFile(rootfile.c_str(),"READ");
  if (fd->IsZombie()) {
    cout << "ERROR: could not open file '"+rootfile+"' for reading." << endl;
    abort();
  }

  // For each objs
  for (auto obj : objs) {
    // Prepare output string
    string outname = formatNameCycle(rootfile,obj);

    // Get obj from file
    TObject *tobj;
    fd->GetObject(obj.c_str(),tobj);

    if (tobj) { // Inherits from TObject
      string sclass = tobj->ClassName();
      unsigned int i; for (i = 0; i < classes.size() && sclass.find(classes[i]) == string::npos; ++i);
      switch (i) {
        case 0: return write((TH1*)tobj,outname);
        case 1: return write((TH2*)tobj,outname);
        case 2: return write((TH3*)tobj,outname);
        case 3: return write((TGraphAsymmErrors*)tobj,outname);
        case 4: return write((TGraphErrors*)tobj,outname);
        case 5: return write((TGraph*)tobj,outname);
        case 6: return write((TF1*)tobj,outname);
        case 7: return write((TVectorF*)tobj,outname);
        case 8: return write((TVectorD*)tobj,outname);
        default: return write(tobj,outname);
      }
    }
    else { // Does not inherit from TObject (currently only TArray supported)
      TArray *tarr;
      fd->GetObject(obj.c_str(),tarr);
      if (tarr) return write(tarr,outname);

      cout << "ERROR: could not find object '"+obj+"' on file '"+rootfile+"'." << endl;
      abort();
    }
  }
}

void usage(char* program)
{
  cout << program << " <.root file> <action> [obj [obj [...]]]" << endl
       << endl
       << "    action (get|list)" << endl
       << "    obj    Is the object identifier in the format 'name,cycle'. One" << endl
       << "           may provide more than one of these. (only 'get')" << endl;
}

int main(int argc, char** argv)
{
  // Parse commandline
  if (argc < 3) {
    cout << "ERROR parsing command line..." << endl;
    usage(argv[0]);
    abort();
  }

  string action = argv[2];
  string rootfile = argv[1];
  if (action == "get") {
    if (argc == 3) {
      cout << "ERROR parsing 'get' command line..." << endl;
      usage(argv[0]);
      abort();
    }
    vector<string> objs;
    for (int i = 3; i < argc; ++i)
      objs.push_back(argv[i]);
    getObjs(rootfile,objs);
  }
  else if (action == "list")
    listRoot(rootfile);
  else {
    cout << "ERROR parsing command line..." << endl;
    usage(argv[0]);
    abort();
  }

  return 0;
}
