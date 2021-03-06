//+------------------------------------------------------------------+
//|                                                CMartinBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMartinBase:public CStrategy
  {
protected:
   double            init_lots; // 初始手数
   double            current_lots; // 当前手数
   OpenSignal        signal;  // 开仓信号
   int               num_failed;  // 连续失败的次数
   MqlTick           latest_price;  // 最新报价

protected:
   virtual void      CalCurrentLots();  // 计算当前手数  
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      TickEventHandle(){};
   virtual void      BarEventHandle(){};
public:
                     CMartinBase(void);
                    ~CMartinBase(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMartinBase::CMartinBase(void)
  {
   init_lots=0.01;
   current_lots=0.01;
   num_failed=0;
   signal=OPEN_SIGNAL_NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMartinBase::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      TickEventHandle();
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      BarEventHandle();
     }
  }
void CMartinBase::CalCurrentLots(void)
   {
    //current_lots=MathPow(2,num_failed)*init_lots;
    current_lots=1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_failed+1)-MathPow((1-sqrt(5))/2,num_failed+1))*init_lots;
    //if(num_failed<=4)
    //  {
    //   current_lots=MathPow(2,num_failed)*init_lots;
    //  }
    //else if(num_failed<10)
    //       {
    //        current_lots=2*(num_failed+4)*init_lots;
    //       }
    //else current_lots=16;
    
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMartinBase::InitBuy(const MarketEvent &event)
  {
   if(event.symbol!=ExpertSymbol()) return;
   if(event.type!=MARKET_EVENT_TICK) return;
   if(signal==OPEN_SIGNAL_BUY&&positions.open_buy==0)
     {
      CalCurrentLots();
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,current_lots,latest_price.ask,0,0,"Buy");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMartinBase::InitSell(const MarketEvent &event)
  {
   if(event.symbol!=ExpertSymbol()) return;
   if(event.type!=MARKET_EVENT_TICK) return;
   if(signal==OPEN_SIGNAL_SELL&&positions.open_sell==0)
     {
      CalCurrentLots();
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,current_lots,latest_price.bid,0,0,"Sell");
     }
  }
//+------------------------------------------------------------------+
