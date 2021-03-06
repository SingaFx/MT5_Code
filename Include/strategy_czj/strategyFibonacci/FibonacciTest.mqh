//+------------------------------------------------------------------+
//|                                                FibonacciTest.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "FibonacciBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFiboTest:public CFibonacciBase
  {
public:
                     CFiboTest(void);
                    ~CFiboTest(void){};
protected:
   virtual void      PatternRecognizedOnBar(); // 在bar事件上进行模式识别
   virtual void      TickEventHandle();
private:
   void     PatternRecognizedMode1();  // 使用最初的模式识别方法
   void     PatternRecognizedMode2();  // 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFiboTest::CFiboTest(void)
  {
   open_ratio=0.382;
   tp_ratio=0.618;
   sl_ratio=-1.0;
   lots_base=0.1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFiboTest::PatternRecognizedOnBar(void)
  {
   PatternRecognizedMode1();
  }
void  CFiboTest::PatternRecognizedMode1(void)
   {
    //计算最高最低价及对应的位置
   double high[],low[];
   int max_loc,min_loc;
   ArrayResize(high,12);
   ArrayResize(low,12);
   CopyHigh(ExpertSymbol(),Timeframe(),0,12,high);
   CopyLow(ExpertSymbol(),Timeframe(),0,12,low);

   max_loc=ArrayMaximum(high);
   min_loc=ArrayMinimum(low);
   max_price=high[max_loc];
   min_price=low[min_loc];
   open_lots=lots_base;
//最高最低价必须超过给定价格差并且两个极值价格间的Bar数必须小于给定的模式最大长度
   if(max_price-min_price>=500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && max_price-min_price<=5*500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && MathAbs(max_loc-min_loc)<=4)
     {
      if(max_loc>min_loc) 
         {
          signal=OPEN_SIGNAL_BUY;
         }
      else if(max_loc<min_loc) 
         {
          signal=OPEN_SIGNAL_SELL;
         }
     }
   else signal=OPEN_SIGNAL_NULL;
   }
void CFiboTest::TickEventHandle(void)
   {
    if(pos_state.num_buy>0&&latest_price.bid<fibo_buy_state.min_price&&bar_counter_after_buy<4)
      {
       Print("###########buy close");
       //Trade.PositionClose(fibo_buy_state.id_pos);
      }
    if(pos_state.num_sell>0&&latest_price.ask>fibo_sell_state.max_price&&bar_counter_after_sell<4)
      {
       Print("#########sell close");
       //Trade.PositionClose(fibo_sell_state.id_pos);
      }
    
   
   }
//+------------------------------------------------------------------+
