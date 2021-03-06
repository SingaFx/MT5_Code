//+------------------------------------------------------------------+
//|                                      SignalRsiMaGridStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "SignalGridStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalRsiMaGridStrategy:public CSignalGridStrategy
  {
protected:
   int               h_rsi;
   int               h_ma_l;
   int               h_ma_s;
   double            v_rsi[];
   double            v_ma_l[];
   double            v_ma_s[];

protected:
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓检测
   void              CheckOpenMode1();
   void              CheckOpenMode2();
   virtual void      RefreshSignal(const MarketEvent &event);
public:
                     CSignalRsiMaGridStrategy(void){};
                    ~CSignalRsiMaGridStrategy(void){};
   virtual void      Init();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiMaGridStrategy::Init(void)
  {
   h_rsi=iRSI(ExpertSymbol(),Timeframe(),14,PRICE_CLOSE);
   h_ma_l=iMA(ExpertSymbol(),PERIOD_H1,800,0,MODE_EMA,PRICE_CLOSE);
   h_ma_s=iMA(ExpertSymbol(),PERIOD_H1,24,0,MODE_EMA,PRICE_CLOSE);
   SetParameters();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiMaGridStrategy::RefreshSignal(const MarketEvent &event)
  {
   CopyBuffer(h_rsi,0,0,1,v_rsi);
   CopyBuffer(h_ma_l,0,0,1,v_ma_l);
   CopyBuffer(h_ma_s,0,0,1,v_ma_s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiMaGridStrategy::CheckPositionOpen(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_BAR_OPEN && event.symbol==ExpertSymbol())
     {
      RefreshSignal(event);
      CheckOpenMode1();
     }
  }
void CSignalRsiMaGridStrategy::CheckOpenMode1(void)
   {
    if(v_ma_l[0]>v_ma_s[0]) // 长均线压制短均线
        {
         if(pos.TotalShort()==0||DistToLastShortPrice()>grid_gap) OpenShortPosition("SN");
         if(pos.TotalLong()==0||DistToLastLongPrice()>10*grid_gap) OpenLongPosition("LE");
        }
      else
        {
         if(pos.TotalLong()==0 || DistToLastLongPrice()>grid_gap) OpenLongPosition("LN");
         if(pos.TotalShort()==0||DistToLastShortPrice()>10*grid_gap) OpenShortPosition("SE");
        }
   }
void CSignalRsiMaGridStrategy::CheckOpenMode2(void)
   {
       if(v_ma_l[0]>v_ma_s[0]) // 长均线压制短均线
        {
         if(pos.TotalShort()==0) OpenShortPosition("DS0");
         else if(pos.TotalShort()<4 && DistToLastShortPrice()>grid_gap) OpenShortPosition("DS1");
         else if(v_rsi[0]>80 && DistToLastShortPrice()>grid_gap) OpenShortPosition("DS2");
         else if(v_rsi[0]>70 && DistToLastShortPrice()>5*grid_gap) OpenShortPosition("DS3");
         else if(DistToLastShortPrice()>10*grid_gap) OpenShortPosition("DS4");
         
         if(v_rsi[0]<10 && DistToLastLongPrice()>grid_gap) OpenLongPosition("DL0");
         else if(v_rsi[0]<20 && DistToLastLongPrice()>5*grid_gap) OpenLongPosition("DL2");
         else if(DistToLastLongPrice()>10*grid_gap) OpenLongPosition("DL3");
        }
      else
        {
         if(pos.TotalLong()==0) OpenLongPosition("UL0");
         else if(pos.TotalLong()<4 && DistToLastLongPrice()>grid_gap) OpenLongPosition("UL1");
         if(v_rsi[0]<20 && DistToLastLongPrice()>grid_gap) OpenLongPosition("UL2");
         else if(v_rsi[0]<30 && DistToLastLongPrice()>5*grid_gap) OpenLongPosition("UL3");
         else if(DistToLastLongPrice()>10*grid_gap) OpenLongPosition("UL4");
         
         if(v_rsi[0]>90 && DistToLastShortPrice()>grid_gap) OpenShortPosition("US0");
         else if(v_rsi[0]>80 && DistToLastShortPrice()>5*grid_gap) OpenShortPosition("US1");
         else if(DistToLastShortPrice()>10*grid_gap) OpenShortPosition("US2");
        }
   }
//+------------------------------------------------------------------+
