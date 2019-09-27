//+------------------------------------------------------------------+
//|                                                         MLMA.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "MLBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMLMA:public CMLBase
  {
protected:
   int               num_ma;
   int               h_ma[];

public:
                     CMLMA(void){};
                    ~CMLMA(void){};
   void              SetMaParameters(ENUM_TIMEFRAMES tf,string sym,int &taus[]);
   void              GetXValue();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMLMA::SetMaParameters(ENUM_TIMEFRAMES tf,string sym,int &taus[])
  {
   num_ma=ArraySize(taus);
   ArrayResize(h_ma,num_ma);
   ArrayResize(x,num_ma);
   for(int i=0;i<num_ma;i++)
     {
      h_ma[i]=iMA(sym,tf,taus[i],0,MODE_EMA,PRICE_CLOSE);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMLMA::GetXValue(void)
  {
   double value[];
   double base;
   for(int i=0;i<num_ma;i++)
     {
      CopyBuffer(h_ma[i],0,0,2,value);
      x[i]=value[0];
     }
   base=x[0];
   for(int i=0;i<num_ma;i++)
     {
      x[i]=x[i]-base;
     }
  }
//+------------------------------------------------------------------+
