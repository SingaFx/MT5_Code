//+------------------------------------------------------------------+
//|                                                    MartinRSI.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "MartinBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMartinMA:public CMartinBase
  {
private:
   int               handle_ma_long;
   int               handle_ma_short;
protected:
   virtual void      TickEventHandle();
public:
                     CMartinMA(void);
                    ~CMartinMA(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMartinMA::CMartinMA(void)
  {
   handle_ma_long=iMA(ExpertSymbol(),Timeframe(),200,0,MODE_SMA,PRICE_CLOSE);
   handle_ma_short=iMA(ExpertSymbol(),Timeframe(),24,0,MODE_SMA,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMartinMA::TickEventHandle(void)
  {
   double ma_long[],ma_short[];
   CopyBuffer(handle_ma_long,0,0,1,ma_long);
   CopyBuffer(handle_ma_short,0,0,1,ma_short);
   if(ma_long[0]>ma_short[0]&&MathAbs(latest_price.bid-ma_long[0])<MathAbs(latest_price.bid-ma_short[0]))
     {
      signal=OPEN_SIGNAL_SELL;
     }
   else if(ma_long[0]<ma_short[0]&&MathAbs(latest_price.ask-ma_long[0])<MathAbs(latest_price.ask-ma_short[0]))
     {
      signal=OPEN_SIGNAL_BUY;
     }
   else
     {
      signal=OPEN_SIGNAL_NULL;
     }
     
   if(positions.open_total>0)
     {
      CPosition *pos=ActivePositions.At(0);
      if(pos.Profit()/pos.Volume()>200)
        {
         //pos.CloseAtMarket("TP");
         Trade.PositionClose(pos.ID());
         num_failed=0;
        }
      else if(pos.Profit()/pos.Volume()<-200)
        {
         Trade.PositionClose(pos.ID());
         //pos.CloseAtMarket("SL");
         num_failed++;
        }
     }
  }
//+------------------------------------------------------------------+
