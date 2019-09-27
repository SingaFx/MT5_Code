//+------------------------------------------------------------------+
//|                                                 StrategyMLMA.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "MLMA.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategyMLMA:public CStrategy
  {
protected:
   MqlTick           latest_price;
   CMLMA             ml;
   int               signal;
public:
                     CStrategyMLMA(void){};
                    ~CStrategyMLMA(void){};
   void              Init();
   void              SetAlpha(double &a[]);
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategyMLMA::Init(void)
  {
   int t[]={1,5,12,24,48,96,240};
   ml.SetMaParameters(PERIOD_M5,ExpertSymbol(),t);
   signal=0;
  }
void CStrategyMLMA::SetAlpha(double &a[])
   {
    ml.SetAlpha(a);
   }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategyMLMA::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      if(signal==1 && positions.open_buy==0)
        {
         double tp=latest_price.ask+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         double sl=latest_price.ask-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,sl,tp);
        }
      if(signal==-1 && positions.open_sell==0)
        {
         double tp=latest_price.bid-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         double sl=latest_price.bid+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,sl,tp);
        }
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      ml.GetXValue();
      double op=ml.OutPut();
      if(op>0) signal=1;
      else if(op<0) signal=-1;
      else signal=0;
     }
  }
//+------------------------------------------------------------------+
