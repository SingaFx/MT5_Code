//+------------------------------------------------------------------+
//|                                             HedgeOperateByMA.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "HedgeBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHedgeOperateByMA:public CHedgeBaseOperate
  {
private:
   int               handle_short_ma;
   int               handle_long_ma;
   double            value_short_ma[];
   double            value_long_ma[];
public:
                     CHedgeOperateByMA(void);
                    ~CHedgeOperateByMA(void);
   virtual void      RefreshIndValues();
   virtual bool      IsUpSignal();
   virtual bool      IsDownSignal();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHedgeOperateByMA::CHedgeOperateByMA(void)
  {
   handle_long_ma=iMA(ExpertSymbol(),PERIOD_H1,200,0,MODE_SMA,PRICE_CLOSE);
   handle_short_ma=iMA(ExpertSymbol(),PERIOD_H1,24,0,MODE_SMA,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeOperateByMA::RefreshIndValues(void)
  {
   CopyBuffer(handle_long_ma,0,0,2,value_long_ma);
   CopyBuffer(handle_short_ma,0,0,2,value_short_ma);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeOperateByMA::IsUpSignal(void)
  {
   if(latest_price.ask<value_short_ma[1] && value_long_ma[1]<value_short_ma[1])
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeOperateByMA::IsDownSignal(void)
  {
   if(latest_price.bid>value_short_ma[1] && value_long_ma[1]>value_short_ma[1])
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
