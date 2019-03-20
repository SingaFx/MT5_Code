//+------------------------------------------------------------------+
//|                                             strategyMACDBase.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMACDBase:public CStrategy
  {
protected:
   int               h_macd;
   int               h_macd_detector;
   double            value_signal[];
   MqlTick           latest_price;
   double            base_lots;

public:
                     CMACDBase(void){};
                    ~CMACDBase(void){};
   void              SetMacdParameters(int ma_fast=12,int ma_slow=26,int sma=9,ENUM_APPLIED_PRICE apply_close=PRICE_CLOSE,int search_bars=100,int extreme_bars=2,double range_price=10,double range_macd=0.0003);
   void              SetBaseLots(double b_l=0.01){base_lots=b_l;};
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionOpen(){};
   virtual void      CheckPositionClose(){};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMACDBase::SetMacdParameters(int ma_fast=12,int ma_slow=26,int sma=9,ENUM_APPLIED_PRICE apply_close=1,int search_bars=100,int extreme_bars=2,double range_price=10.000000,double range_macd=0.000300)
  {
   h_macd_detector=iCustom(ExpertSymbol(),Timeframe(),"CZJIndicators\\Detectors\\MacdDetector2",ma_fast,ma_slow,sma,apply_close,search_bars,extreme_bars,range_price,range_macd);
   h_macd=iMACD(ExpertSymbol(),Timeframe(),ma_fast,ma_slow,sma,apply_close);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMACDBase::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionClose();
     }
  }
//+------------------------------------------------------------------+
