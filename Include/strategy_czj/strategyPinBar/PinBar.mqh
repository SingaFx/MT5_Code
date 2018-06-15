//+------------------------------------------------------------------+
//|                                                       PinBar.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPinBarStrategy:public CStrategy
  {
protected:
   int               handle_pinbar;
   double            open_lots;
   ENUM_ORDER_TYPE   order_type;
   double            open_price;
   double            tp_price;
   double            sl_price;
   double            signal[3];// -1 卖； 0 不操作； 1 买
   double            point_range[];
   bool              is_new_bar;
   double            open[3];
   double            close[3];
   double            high[3];
   double            low[3];
   MqlTick           latest_price;
public:
                     CPinBarStrategy(void);
                    ~CPinBarStrategy(void){};
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CalPrices(); // 计算signal,open_price, tp_price, sl_price
private:
   void              CalPriceMode1();
   void              CalPriceMode2();
   void              CalPriceMode3();
   void              CalPriceMode4();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPinBarStrategy::CPinBarStrategy(void)
  {
   handle_pinbar=iCustom(ExpertSymbol(),Timeframe(),"PinbarDetector");
   open_lots=0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CalPrices();
      if(signal[1]==1 && is_new_bar && latest_price.ask>open_price)//buy
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,sl_price,tp_price,ExpertNameFull());
         is_new_bar=false;
        }
      else if(signal[1]==-1 && is_new_bar && latest_price.bid<open_price)//sell
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,sl_price,tp_price,ExpertNameFull());
         is_new_bar=false;
        }
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      is_new_bar=true;
      CopyBuffer(handle_pinbar,2,0,3,signal);
      CopyBuffer(handle_pinbar,3,0,3,point_range);
      CopyOpen(_Symbol,_Period,0,3,open);
      CopyHigh(_Symbol,_Period,0,3,high);
      CopyLow(_Symbol,_Period,0,3,low);
      CopyClose(_Symbol,_Period,0,3,close);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::CalPrices(void)
  {
//CalPriceMode1();
//CalPriceMode2();
   //CalPriceMode3();
   CalPriceMode4();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::CalPriceMode1(void)
  {
   if(signal[1]==1.0) // buy
     {
      open_price=high[1];
      sl_price=low[1];
      tp_price=open[0];
     }
   else if(signal[1]==-1.0)// sell
     {
      open_price=low[1];
      sl_price=high[1];
      tp_price=open[0];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::CalPriceMode2(void)
  {
   if(signal[1]==1.0) // buy
     {
      open_price=high[1];
      sl_price=open_price-2000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      tp_price=open_price+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
     }
   else if(signal[1]==-1.0)// sell
     {
      open_price=low[1];
      sl_price=open_price+2000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      tp_price=open_price-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPinBarStrategy::CalPriceMode3(void)
  {
   if(signal[1]==1.0) // buy
     {
      
      open_price=high[1];
      sl_price=open_price-1.618*point_range[1];
      tp_price=open_price+0.618*point_range[1];
     }
   else if(signal[1]==-1.0)// sell
     {
      
      open_price=low[1];
      sl_price=open_price+1.618*point_range[1];
      tp_price=open_price-0.618*point_range[1];
     }
  }
void  CPinBarStrategy::CalPriceMode4(void)
  {
   if(signal[1]==1.0) // buy
     {
      
      open_price=high[1];
      sl_price=low[1]-1.618*point_range[1];
      tp_price=low[1]+0.618*point_range[1];
     }
   else if(signal[1]==-1.0)// sell
     {
      
      open_price=low[1];
      sl_price=high[1]+1.618*point_range[1];
      tp_price=high[1]-0.618*point_range[1];
     }
  }
//+------------------------------------------------------------------+
