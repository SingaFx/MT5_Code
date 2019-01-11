//+------------------------------------------------------------------+
//|                                            HedgeOperateByRSI.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "HedgeBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHedgeOperateByRSI:public CHedgeBaseOperate
  {
private:
   double rsi_down_level;
   double rsi_up_level;
public:
                     CHedgeOperateByRSI(void);
                    ~CHedgeOperateByRSI(void);
   virtual void      RefreshIndValues();
   virtual bool      IsUpSignal();
   virtual bool      IsDownSignal();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHedgeOperateByRSI::CHedgeOperateByRSI(void)
  {
   ind_handle=iRSI(ExpertSymbol(),PERIOD_H1,12,PRICE_CLOSE);
   rsi_down_level=30;
   rsi_up_level=70;
  }
void CHedgeOperateByRSI::RefreshIndValues(void)
   {
    CopyBuffer(ind_handle,0,0,2,ind_value);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeOperateByRSI::IsUpSignal(void)
  {
   if(ind_value[0]<rsi_down_level) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeOperateByRSI::IsDownSignal(void)
  {
   if(ind_value[0]>rsi_up_level) return true;
   return false;
  }
//+------------------------------------------------------------------+
