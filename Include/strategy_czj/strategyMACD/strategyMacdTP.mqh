//+------------------------------------------------------------------+
//|                                               strategyMacdTP.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "strategyMACDBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategyMacdTP:public CMACDBase
  {
private:
   int               tp;
   int               sl;
   double            tp_price;
   double            sl_price;

public:
                     CStrategyMacdTP(void){};
                    ~CStrategyMacdTP(void){};
   void              SetParametersTP(int tp_points=500,int sl_points=500);
protected:
   virtual void      CheckPositionOpen();
   virtual void      CheckPositionClose(){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategyMacdTP::SetParametersTP(int tp_points=500,int sl_points=500)
  {
   tp=tp_points;
   sl=sl_points;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategyMacdTP::CheckPositionOpen(void)
  {
   CopyBuffer(h_macd_detector,2,0,1,value_signal);
   if(value_signal[0]==1)
     {
      Print("Buy");
      tp_price=latest_price.ask+tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.ask-sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,sl_price,tp_price);
     }
   else if(value_signal[0]==-1)
     {
      Print("Sell");
      tp_price=latest_price.bid-tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.bid+sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,sl_price,tp_price);
     }
  }
//+------------------------------------------------------------------+
