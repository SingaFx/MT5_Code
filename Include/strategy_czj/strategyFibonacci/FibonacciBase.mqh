//+------------------------------------------------------------------+
//|                                                FibonacciBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>

struct FibonacciState
  {
   double max_price;
   double min_price;
   int bar_num;
   ulong id_pos;
   void Init(double price_max, double price_min, ulong pos_id, int num_bar=0);
  };
FibonacciState::Init(double price_max, double price_min, ulong pos_id, int num_bar=0)
   {
    max_price=price_max;
    min_price=price_min;
    bar_num=num_bar;
    id_pos=pos_id;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFibonacciBase:public CStrategy
  {
protected:
   double            open_ratio;   // Fibo回调的开仓比例
   double            tp_ratio;  // Fibo的止盈比例
   double            sl_ratio;  // Fibo的止损比例
   double            lots_base;  // 基础手数

   double            max_price;// 模式最大值
   double            min_price; // 模式最小值
   double            open_lots; // 开仓手数
   OpenSignal        signal;  // 开仓信号
   PositionInfor     pos_state;  // 仓位状态
   FibonacciState fibo_buy_state;  // 存储Fibo买的状态
   FibonacciState fibo_sell_state; // 存储Fibo卖的状态
   MqlTick           latest_price;   // 最新的tick报价
   string            order_comment; // 订单comment
   
   int               bar_counter_after_buy;  // 下买单后的新生成的bar数
   int               bar_counter_after_sell; // 下卖单后的新生成的bar数
   
private:
   double            open_price;   // 开仓价格
   double            tp_price;  // 止盈价格
   double            sl_price;  // 止损价格
protected:
   void              RefreshPositionState(); // 刷新仓位信息
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      PatternRecognizedOnBar(){}; // 在bar事件上进行Fibonacci模式识别: 计算max_price, min_price, signal, open_lots
   virtual void      TickEventHandle(){}; // 预留tick事件的其他处理
public:
                     CFibonacciBase(void){};
                    ~CFibonacciBase(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciBase::RefreshPositionState(void)
  {
   pos_state.Init();
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) pos_state.num_buy++;
      else pos_state.num_sell++;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciBase::InitBuy(const MarketEvent &event)
  {
   if(pos_state.num_buy>0) return;//只能允许一个仓位
   open_price=open_ratio*(max_price-min_price)+min_price;
   int symbol_digits=(int)SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS);
   tp_price=NormalizeDouble(tp_ratio*(max_price-min_price)+min_price,symbol_digits);
   sl_price=NormalizeDouble(sl_ratio*(max_price-min_price)+min_price,symbol_digits);
   order_comment="buy <- max:"+DoubleToString(max_price,symbol_digits)+", min:"+DoubleToString(min_price,symbol_digits);
   if(signal==OPEN_SIGNAL_BUY && latest_price.ask<open_price)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,sl_price,tp_price,order_comment);
      signal=OPEN_SIGNAL_NULL;
      fibo_buy_state.Init(max_price,min_price,Trade.ResultOrder());
      bar_counter_after_buy=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciBase::InitSell(const MarketEvent &event)
  {
   if(pos_state.num_sell>0) return;//只能允许一个仓位
   open_price=max_price-open_ratio*(max_price-min_price);
   int symbol_digits=(int)SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS);
   tp_price=NormalizeDouble(max_price-tp_ratio*(max_price-min_price),symbol_digits);
   sl_price=NormalizeDouble(max_price-sl_ratio*(max_price-min_price),symbol_digits);
   order_comment="sell <- max:"+DoubleToString(max_price,symbol_digits)+", min:"+DoubleToString(min_price,symbol_digits);
   if(signal==OPEN_SIGNAL_SELL && latest_price.bid>open_price)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,sl_price,tp_price,order_comment);
      signal=OPEN_SIGNAL_NULL;
      fibo_sell_state.Init(max_price,min_price,Trade.ResultOrder());
      bar_counter_after_sell=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFibonacciBase::OnEvent(const MarketEvent &event)
  {
//新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshPositionState();
      if(pos_state.num_buy>0) bar_counter_after_buy++;
      if(pos_state.num_sell>0) bar_counter_after_sell++;
      PatternRecognizedOnBar();
     }
//tick事件发生时，需要进行最新价格获取，仓位信息的获取(用于后续可能的开仓)
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionState();
      TickEventHandle();
     }
  }
//+------------------------------------------------------------------+
