//+------------------------------------------------------------------+
//|                                              LightingReverse.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "strategyBasedOnZigZag.mqh"
#include <strategy_czj\common\strategy_common.mqh>

class CLightingReverse:public CStrategyBasedOnZigZag
  {
private:
   double ratio_reverse;
   double ratio_trend;
   double ratio_open;

   MqlTick latest_price;
   OpenSignal signal;
   double   order_lots;
   double open_price;
   double tp_price;
   double sl_price;
   string comment;
public:
                     CLightingReverse(void);
                    ~CLightingReverse(void){};
                    void SetParameter(double r_reverse, double r_trend, double r_open, double lots_open);
protected:
   virtual void      OnEvent(const MarketEvent &event); 
   void              PatternRecognize();
   bool              BuyCondition();
   bool              SellCondition();
  };
CLightingReverse::CLightingReverse(void)
   {
    order_lots=0.1;
    signal=OPEN_SIGNAL_NULL;
    ratio_reverse = 0.4;
    ratio_trend = 0.8;
    ratio_open = 0.2;
   }
void CLightingReverse::SetParameter(double r_reverse,double r_trend,double r_open,double lots_open)
   {
    ratio_reverse = r_reverse;
    ratio_trend = r_trend;
    ratio_open = r_open;
    order_lots = lots_open;
   }
void CLightingReverse::PatternRecognize(void)
   {
    if(zz_value[0]>zz_value[1]&&dist_v[0]>=ratio_trend*dist_v[2]&&dist_v[2]!=0&&dist_v[1]/dist_v[2]<ratio_reverse)
      {
       signal=OPEN_SIGNAL_SELL;
       open_price=zz_value[0]-ratio_open*dist_v[0];
       tp_price = zz_value[1];
       sl_price = zz_value[0]+dist_v[0];
       return;
      }
    if(zz_value[0]<zz_value[1]&&dist_v[0]>=ratio_trend*dist_v[2]&&dist_v[2]!=0&&dist_v[1]/dist_v[2]<ratio_reverse)
      {
       signal=OPEN_SIGNAL_BUY;
       open_price=zz_value[0]+ratio_open*dist_v[0];
       tp_price = zz_value[1];
       sl_price = zz_value[0]-dist_v[0];
       return;
      }
    signal=OPEN_SIGNAL_NULL;
   }
bool CLightingReverse::BuyCondition(void)
   {
    if(signal==OPEN_SIGNAL_BUY&&latest_price.ask>open_price&&pos_state.num_buy==0) return true;
    return false;
   }
bool CLightingReverse::SellCondition(void)
   {
    if(signal==OPEN_SIGNAL_SELL&&latest_price.bid<open_price&&pos_state.num_sell==0) return true;
    return false;
   }
void CLightingReverse::OnEvent(const MarketEvent &event)
   {
    //新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      GetZigZagValues();   // 取zigzag非0值
      PatternRecognize();  // 进行模式识别
     }
   //tick事件发生时，对应的处理
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionState();
      if(BuyCondition())
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY, order_lots,latest_price.ask,sl_price,tp_price,comment)) return;
        }
      if(SellCondition())
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL, order_lots,latest_price.bid,sl_price,tp_price,comment)) return;
        }
     }
   }