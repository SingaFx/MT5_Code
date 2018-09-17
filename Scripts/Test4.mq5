//+------------------------------------------------------------------+
//|                                                        Test4.mq5 |
//|                                                                  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Math\Alglib\alglib.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int npoints=1000;
   CMatrixDouble xy;
   xy.Resize(npoints,1);
   double close[];
   CopyClose(_Symbol,_Period,0,npoints,close);
   for(int i=0;i<npoints;i++)
     {
      xy[i].Set(0,close[i]);
     }
       
   int nvars=1;
   int k=5;
   int restarts=2;
   int infor;
   CMatrixDouble c;
   int xyc[];
   CAlglib alg;
   alg.KMeansGenerate(xy,npoints,nvars,k,restarts,infor,c,xyc);
   Print(c.Size());
   Print("infor:",infor);
   Print("size of xyc:", ArraySize(xyc));
   for(int i=0;i<k;i++)
     {
      Print(c[0][i]);
     }
   //KMeansGenerate(CMatrixDouble &xy,const int npoints,
   //                                 const int nvars,const int k,
   //                                 const int restarts,int &info,
   //                                 CMatrixDouble &c,int &xyc[])
  }
//+------------------------------------------------------------------+
