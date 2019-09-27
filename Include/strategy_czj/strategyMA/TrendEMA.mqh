//+------------------------------------------------------------------+
//|                                                     TrendEMA.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PosState
  {
   bool              is_open;
   long              pos_id;
   double            GetProfits();
   double            GetProfitsPerLots();
   void Init(){is_open=false;};
   void              Add(long pid);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PosState::Add(long pid)
  {
   pos_id=pid;
   is_open=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PosState::GetProfitsPerLots(void)
  {
   PositionSelectByTicket(pos_id);
   return PositionGetDouble(POSITION_PROFIT)/PositionGetDouble(POSITION_VOLUME);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PosState::GetProfits(void)
  {
   PositionSelectByTicket(pos_id);
   return PositionGetDouble(POSITION_PROFIT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrendEMA:public CStrategy
  {
protected:
   int               h_w_long;
   int               h_w_short;
   int               h_ema_close;
   int               h_ema_high;
   int               h_ema_low;
   double            buffer_w_long[];
   double            buffer_w_short[];
   double            buffer_ema_close[];
   double            buffer_ema_high[];
   double            buffer_ema_low[];

   PosState          long3[3];
   PosState          short3[3];

   double            l_high;
   double            l_low;
   double            l_medium;

   MqlTick           latest_price;
public:
                     CTrendEMA(void){};
                    ~CTrendEMA(void){};
   void              InitHandles(int ema_close_period=50,int ema_high_period=150,int ema_low_period=150,int w_long_period=100,int w_short_period=10);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              CheckLongPositionOpen();
   void              CheckShortPositionOpen();
   void              CheckLongPositionClose();
   void              CheckShortPositionClose();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendEMA::InitHandles(int ema_close_period=50,int ema_high_period=150,int ema_low_period=150,int w_long_period=100,int w_short_period=10)
  {
   h_ema_close=iMA(ExpertSymbol(),Timeframe(),ema_close_period,0,MODE_EMA,PRICE_CLOSE);
   h_ema_high=iMA(ExpertSymbol(),Timeframe(),ema_high_period,0,MODE_EMA,PRICE_HIGH);
   h_ema_low=iMA(ExpertSymbol(),Timeframe(),ema_low_period,0,MODE_EMA,PRICE_LOW);
   h_w_long=iWPR(ExpertSymbol(),Timeframe(),w_long_period);
   h_w_short=iWPR(ExpertSymbol(),Timeframe(),w_short_period);
   l_high=0.01;
   l_medium=0.02;
   l_low=0.03;
   for(int i=0;i<3;i++)
     {
      long3[i].Init();
      short3[i].Init();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendEMA::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CopyBuffer(h_w_long,0,0,10,buffer_w_long);
      CopyBuffer(h_w_short,0,0,10,buffer_w_short);
      CopyBuffer(h_ema_close,0,0,10,buffer_ema_close);
      CopyBuffer(h_ema_high,0,0,10,buffer_ema_high);
      CopyBuffer(h_ema_low,0,0,10,buffer_ema_low);
      CheckLongPositionOpen();
      CheckShortPositionOpen();

     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckLongPositionClose();
      CheckShortPositionClose();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendEMA::CheckLongPositionOpen(void)
  {
   if(buffer_ema_close[9]>buffer_ema_high[9] && buffer_w_long[9]>-20)
     {
      bool b1=buffer_w_short[9]<-30;
      bool b2=latest_price.ask<buffer_ema_close[9];
      bool b3=Close[1]-Open[1]>2*MathAbs(Close[2]-Open[2]);
      //if(b1 && b2 && b3)
      //  {
      //   if(!long3[2].is_open)
      //     {
      //      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l_low,latest_price.ask,0,0,"L-Risk");
      //      long3[2].Add(Trade.ResultOrder());
      //     }
      //  }
      //else if(b1 && b2)
      //  {
      //   if(!long3[1].is_open)
      //     {
      //      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l_medium,latest_price.ask,0,0,"M-Risk");
      //      long3[1].Add(Trade.ResultOrder());
      //     }
      //  }
      if(b2&&b1)
        {
         if(!long3[0].is_open)
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l_high,latest_price.ask,0,0,"HighRisk");
            long3[0].Add(Trade.ResultOrder());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendEMA::CheckShortPositionOpen(void)
  {
   if(buffer_ema_close[9]<buffer_ema_low[9] && buffer_w_long[9]<-80)
     {
      bool b1=buffer_w_short[9]>-70;
      bool b2=latest_price.bid>buffer_ema_close[9];
      bool b3=Open[1]-Close[1]>2*MathAbs(Close[2]-Open[2]);
      //if(b1 && b2 && b3)
      //  {
      //   if(!short3[2].is_open)
      //     {
      //      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l_low,latest_price.bid,0,0,"L-Risk");
      //      short3[2].Add(Trade.ResultOrder());
      //     }
      //  }
      //else if(b1 && b2)
      //  {
      //   if(!short3[1].is_open)
      //     {
      //      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l_medium,latest_price.bid,0,0,"M-Risk");
      //      short3[1].Add(Trade.ResultOrder());
      //     }
      //  }
      if(b2&&b1)
        {
         if(!short3[0].is_open)
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l_high,latest_price.bid,0,0,"HighRisk");
            short3[0].Add(Trade.ResultOrder());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendEMA::CheckLongPositionClose(void)
  {
   if(long3[0].is_open && (MathAbs(long3[0].GetProfitsPerLots())>200 || buffer_ema_close[9]<buffer_ema_high[9]))
     {
      Trade.PositionClose(long3[0].pos_id);
      long3[0].Init();
     }

   if(long3[1].is_open && (MathAbs(long3[1].GetProfitsPerLots())>200 || buffer_ema_close[9]<buffer_ema_high[9]))
     {
      Trade.PositionClose(long3[1].pos_id);
      long3[1].Init();
     }

   if(long3[2].is_open && (MathAbs(long3[2].GetProfitsPerLots())>200 || buffer_ema_close[9]<buffer_ema_high[9]))
     {
      Trade.PositionClose(long3[2].pos_id);
      long3[2].Init();
     }
  }
void CTrendEMA::CheckShortPositionClose(void)
   {
      if(short3[0].is_open && (MathAbs(short3[0].GetProfitsPerLots())>200 || buffer_ema_close[9]>buffer_ema_low[9]))
        {
         Trade.PositionClose(short3[0].pos_id);
         short3[0].Init();
        }

      if(short3[1].is_open && (MathAbs(short3[1].GetProfitsPerLots())>200 || buffer_ema_close[9]>buffer_ema_low[9]))
        {
         Trade.PositionClose(short3[1].pos_id);
         short3[1].Init();
        }

      if(short3[2].is_open && (MathAbs(short3[2].GetProfitsPerLots())>200 || buffer_ema_close[9]>buffer_ema_low[9]))
        {
         Trade.PositionClose(short3[2].pos_id);
         short3[2].Init();
        }
   }
//+------------------------------------------------------------------+
