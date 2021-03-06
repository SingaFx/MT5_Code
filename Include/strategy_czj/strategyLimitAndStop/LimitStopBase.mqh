//+------------------------------------------------------------------+
//|                                                LimitStopBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>

enum OpenSignalType
  {
   ENUM_OPEN_SIGNAL_NULL,
   ENUM_OPEN_SIGNAL_LIMIT_BUY,
   ENUM_OPEN_SIGNAL_LIMIT_SELL,
   ENUM_OPEN_SIGNAL_STOP_BUY,
   ENUM_OPEN_SIGNAL_STOP_SELL,
  };

class CLimitAndStopBase:public CStrategy
  {
protected:
   double open_price; // 开仓价格(可能是回调价格或者突破价格)
   double tp_price;  // 止盈价格
   double sl_price;  // 止损价格
   OpenSignalType open_signal;   // 开仓信号类型
   MqlTick latest_price;   // 最新的tick报价
   double open_lots; // 开仓手数
public:
                     CLimitAndStopBase(void){};
                    ~CLimitAndStopBase(void){};
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event); 
   // 模式识别--在bar事件中进行，需要计算open_signal, 及对应的open_price,tp_price, sl_price,如果手数需要调整，也要计算open_lots                   
   virtual void      PatternRecognize(){};  
  };

void CLimitAndStopBase::OnEvent(const MarketEvent &event)
   {
    // 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      PatternRecognize();
     }
   }
void CLimitAndStopBase::InitBuy(const MarketEvent &event)
   {
    if(event.symbol!=ExpertSymbol()) return;
    if(event.type!=MARKET_EVENT_TICK) return;
    if(positions.open_buy>0) return;
    if(open_signal==ENUM_OPEN_SIGNAL_LIMIT_BUY&&latest_price.ask<open_price)  // limit buy 回调买入
      {
       Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,open_price,sl_price,tp_price,"LimitBuy");
      }
    if(open_signal==ENUM_OPEN_SIGNAL_STOP_BUY&&latest_price.bid>open_price)   // stop buy 突破买入
      {
       Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,open_price,sl_price,tp_price,"StopBuy");
      }
   }  
void CLimitAndStopBase::InitSell(const MarketEvent &event)
   {
    if(event.symbol!=ExpertSymbol()) return;
    if(event.type!=MARKET_EVENT_TICK) return;
    if(positions.open_sell>0) return;
    if(open_signal==ENUM_OPEN_SIGNAL_LIMIT_SELL&&latest_price.bid>open_price)  // limit sell 回调卖出
      {
       Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,open_price,sl_price,tp_price,"LimitSell");
      }
    if(open_signal==ENUM_OPEN_SIGNAL_STOP_SELL&&latest_price.ask<open_price)   // stop sell 突破卖出
      {
       Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,open_price,sl_price,tp_price,"StopSell");
      }
   }
