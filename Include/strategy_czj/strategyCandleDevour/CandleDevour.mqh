//+------------------------------------------------------------------+
//|                                                 CandleDevour.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>

class CCandleDevour:public CStrategy
  {
private:
   int handle_candle_devour;
   double signal[3];
   double support_level[];
   double resistence_level[];
   MqlTick latest_price;
   bool is_new_bar;
   double open_lots;
   double tp;
   double sl;
   
public:
                     CCandleDevour(void);
                    ~CCandleDevour(void){};
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
CCandleDevour::CCandleDevour(void)
   {
    handle_candle_devour = iCustom(ExpertSymbol(),Timeframe(),"MyIndicators/CZJIndicators/IndCandleDevour");
    open_lots=0.01;
   }
CCandleDevour::OnEvent(const MarketEvent &event)
   {
    // 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      if(signal[1]==1 && is_new_bar)//buy
        {
         tp=(resistence_level[1]-support_level[1])*0.618+support_level[1];
         sl=support_level[1]-(resistence_level[1]-support_level[1])*0.618;
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,sl,tp);
         is_new_bar=false;
        }
      else if(signal[1]==-1 && is_new_bar)//sell
        {
         tp=resistence_level[1]-(resistence_level[1]-support_level[1])*0.618;
         sl=resistence_level[1]+(resistence_level[1]-support_level[1])*0.618;
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,resistence_level[1],support_level[1],ExpertNameFull());
         is_new_bar=false;
        }
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      is_new_bar=true;
      CopyBuffer(handle_candle_devour,2,0,3,support_level);
      CopyBuffer(handle_candle_devour,3,0,3,resistence_level);
      CopyBuffer(handle_candle_devour,4,0,3,signal);
     }
   
   }