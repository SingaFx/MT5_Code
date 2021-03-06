//+------------------------------------------------------------------+
//|                                                TrendCallBack.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>
#include "ClassMapping.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrendCallBack:public CStrategy
  {
protected:
   int               points_bt; // 趋势进场的回撤点数
   MqlTick           latest_price;  // 最新的tick报价
   double            max_price;  // 最高价
   double            min_price;  // 最低价
   double            high_arr[];
   double            low_arr[];
   int               trend_direction;  //趋势方向
   int               i_high;
   int               i_low;
   double            tp_price;
   double            sl_price;
   datetime          last_buy_time;
   datetime          last_sell_time;

   CBandsRsiMapping  map;
   int               signal;
public:
                     CTrendCallBack(void){};
                    ~CTrendCallBack(void){};
   void              Init();
   void              SetMappingIndex(int map_index=0){map.SetCurrentCodeIndex(map_index);};
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              CheckPositionOpen();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendCallBack::Init(void)
  {
   points_bt=150;
   trend_direction=0;
   map.InitMapping();
   map.InitHandles(ExpertSymbol());
   signal=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendCallBack::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CopyHigh(ExpertSymbol(),Timeframe(),0,24,high_arr);
      CopyLow(ExpertSymbol(),Timeframe(),0,24,low_arr);
      i_high=ArrayMaximum(high_arr);
      i_low=ArrayMinimum(low_arr);
      max_price=high_arr[i_high];
      min_price=low_arr[i_low];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendCallBack::CheckPositionOpen(void)
  {
   if(i_high==0||i_low==0||i_high==23||i_low==23) return;
   signal=map.Classify(latest_price);
   if(i_high>i_low)
     {
      if(positions.open_buy>0&&latest_price.time-last_buy_time<60*60*4) return;
      if(signal==1 && max_price-latest_price.ask>SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)*points_bt)
        {
         tp_price=latest_price.ask+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         sl_price=latest_price.ask-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,sl_price,tp_price);
         last_buy_time=latest_price.time;
        }
     }
   if(i_high<i_low)
     {
      if(positions.open_sell>0&&latest_price.time-last_sell_time<60*60*4) return;
      if(signal==2 && latest_price.bid-min_price>SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)*points_bt)
        {
         tp_price=latest_price.bid-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         sl_price=latest_price.bid+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,sl_price,tp_price);
         last_sell_time=latest_price.time;
        }
     }
  }
//+------------------------------------------------------------------+
