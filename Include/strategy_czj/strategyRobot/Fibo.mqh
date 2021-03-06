//+------------------------------------------------------------------+
//|                                                         Fibo.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>
#include "MLMA.mqh"

class CFiboTrend:public CStrategy
  {
protected:
   int               h;
   
   double            s1[];
   double            s2[];
   double            s3[];
   double            reverse[];
   double            trend[];
   MqlTick           latest_price;
   double            last_buy;
   double            last_sell;
      
   CMLMA             ml;
   int               signal;
   
protected:
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CFiboTrend(void){};
                    ~CFiboTrend(void){};
   void              Init();
   void              SetAlpha(double &a[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFiboTrend::Init(void)
  {
   h=iCustom(ExpertSymbol(),Timeframe(),"CZJIndicators\\Manual\\TrendFibo");
   CopyBuffer(h,0,0,2,s1);
   CopyBuffer(h,1,0,2,s2);
   CopyBuffer(h,2,0,2,s3);
   CopyBuffer(h,3,0,2,reverse);
   CopyBuffer(h,4,0,2,trend);
   int t[]={1,5,12,24,48,96,240};
   ml.SetMaParameters(PERIOD_H1,ExpertSymbol(),t);
   signal=0;
  }
void CFiboTrend::SetAlpha(double &a[])
   {
    ml.SetAlpha(a);
   }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFiboTrend::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      
      if(signal==1&&trend[0]==1&&latest_price.ask<s2[0]&&positions.open_buy==0)
        {
         double tp_price=latest_price.ask+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         double sl_price=latest_price.ask-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,sl_price,tp_price);
         last_buy=latest_price.ask;
        }
      else if(signal==-1&&trend[0]==-1&&latest_price.bid>s2[0]&&positions.open_sell==0)
             {
               double tp_price=latest_price.bid-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
               double sl_price=latest_price.bid+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
               Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,sl_price,tp_price);
               last_sell=latest_price.bid;
             }
            
     }

   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CopyBuffer(h,0,0,2,s1);
      CopyBuffer(h,1,0,2,s2);
      CopyBuffer(h,2,0,2,s3);
      CopyBuffer(h,3,0,2,reverse);
      CopyBuffer(h,4,0,2,trend);
      
      ml.GetXValue();
      double op=ml.OutPut();
      if(op>0) signal=1;
      else if(op<0) signal=-1;
      else signal=0;
     }
  }
//+------------------------------------------------------------------+
