//+------------------------------------------------------------------+
//|                                             strategyMacdBoll.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "strategyMACDBase.mqh"
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMacdBand:public CMACDBase
  {
private:
   int               handle_band;
   double            bands_top[];
   double            bands_bottom[];
   CArrayLong        pos_id_long;
   CArrayLong        pos_id_short;
protected:
   virtual void      CheckPositionOpen();
   virtual void      CheckPositionClose();
public:
                     CMacdBand(void){};
                    ~CMacdBand(void){};
   void              SetParameterBand(int ma_period=24,double deviation=2.0);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMacdBand::SetParameterBand(int ma_period=24,double deviation=2.0)
  {
   handle_band=iBands(ExpertSymbol(),Timeframe(),ma_period,0,deviation,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMacdBand::CheckPositionOpen(void)
  {
   CopyBuffer(h_macd_detector,2,0,1,value_signal);
   if(value_signal[0]==1)
     {
      Print("Buy");
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,0,0);
      pos_id_long.Add(Trade.ResultOrder());
     }
   else if(value_signal[0]==-1)
     {
      Print("Sell");
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,0,0);
      pos_id_short.Add(Trade.ResultOrder());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMacdBand::CheckPositionClose(void)
  {
   CopyBuffer(handle_band,1,0,2,bands_top);
   CopyBuffer(handle_band,2,0,2,bands_bottom);
   if(latest_price.bid>bands_top[0] || latest_price.ask<bands_bottom[0])
     {
      for(int i=pos_id_long.Total()-1;i>=0;i--)
        {
         Trade.PositionClose(pos_id_long.At(i));
        }
      for(int i=pos_id_short.Total();i>=0;i--)
        {
         Trade.PositionClose(pos_id_short.At(i));
        }
     }
  }
//+------------------------------------------------------------------+
