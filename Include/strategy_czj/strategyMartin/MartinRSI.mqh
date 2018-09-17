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
class CMartinRSI:public CMartinBase
  {
private:
   int               handle_rsi;
protected:
   virtual void      TickEventHandle();
public:
                     CMartinRSI(void);
                    ~CMartinRSI(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMartinRSI::CMartinRSI(void)
  {
   handle_rsi=iRSI(ExpertSymbol(),Timeframe(),12,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMartinRSI::TickEventHandle(void)
  {
   double rsi_value[];
   CopyBuffer(handle_rsi,0,0,1,rsi_value);

   //double rsi_up=70+2*num_failed;
   //double rsi_down=30-2*num_failed;
   //double rsi_up=70+20*(1-exp(-0.5*num_failed));
   //double rsi_down=30-20*(1-exp(-0.5*num_failed));
   double rsi_up=70;
   double rsi_down=30;
   
   if(rsi_value[0]>rsi_up)
     {
      signal=OPEN_SIGNAL_SELL;
     }
   else if(rsi_value[0]<rsi_down)
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
