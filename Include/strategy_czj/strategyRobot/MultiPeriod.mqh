//+------------------------------------------------------------------+
//|                                                  MultiPeriod.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMultiPeriod:public CStrategy
  {
protected:
   MqlTick           latest_price;
   MqlRates          week[];
   MqlRates          daily[];
   MqlRates          h4[];
   MqlRates          h1[];
   MqlRates          m5[];
   datetime          last_buy_time;
   datetime          last_sell_time;
   double tp_price;
   double sl_price;
public:
                     CMultiPeriod(void){};
                    ~CMultiPeriod(void){};
                    void Init();
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              CheckPositionOpen();
   bool              BaseCondition();
   bool              BuyCondition();
   bool              SellCondition();
  };
void CMultiPeriod::Init()
   {
      CopyRates(ExpertSymbol(),PERIOD_W1,0,2,week);
      CopyRates(ExpertSymbol(),PERIOD_D1,0,2,daily);
      CopyRates(ExpertSymbol(),PERIOD_H4,0,2,h4);
      CopyRates(ExpertSymbol(),PERIOD_H1,0,2,h1);
      //CopyRates(ExpertSymbol(),PERIOD_M5,0,2,m5);
   }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiPeriod::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CopyRates(ExpertSymbol(),PERIOD_W1,0,2,week);
      CopyRates(ExpertSymbol(),PERIOD_D1,0,2,daily);
      CopyRates(ExpertSymbol(),PERIOD_H4,0,2,h4);
      CopyRates(ExpertSymbol(),PERIOD_H1,0,2,h1);
      //CopyRates(ExpertSymbol(),PERIOD_M5,0,2,m5);
     }
  } 
void CMultiPeriod::CheckPositionOpen(void)
   {
    if(!BaseCondition()) return;
    if(BuyCondition())
      {
        tp_price=latest_price.ask+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
          sl_price=latest_price.ask-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,sl_price,tp_price);
          last_buy_time=latest_price.time;
      }
    if(SellCondition())
      {
       tp_price=latest_price.bid-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
          sl_price=latest_price.bid+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,sl_price,tp_price);
          last_sell_time=latest_price.time;
      }      
   }    
bool CMultiPeriod::BaseCondition(void)
   {
    if(latest_price.ask-latest_price.bid>20*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return false;
    if(week[0].high>daily[0].high&&week[0].low<daily[0].low&&daily[0].high>h4[0].high&&daily[0].low<h4[0].low&&h4[0].high>h1[0].high&&h4[0].low<h1[0].low) return true;
    return false;
   }
bool CMultiPeriod::BuyCondition(void)
   {
    if(positions.open_buy>0&&latest_price.time-last_buy_time<60*60) return false;
    bool b1=latest_price.ask<(week[0].high-week[0].low)*0.382+week[0].low;
    bool b2=latest_price.ask<(daily[0].high-daily[0].low)*0.382+daily[0].low;
    bool b3=latest_price.ask<(h4[0].high-h4[0].low)*0.382+h4[0].low;
    bool b4=latest_price.ask<(h1[0].high-h1[0].low)*0.382+h1[0].low;
   // bool b5=latest_price.ask<(m5[0].high-m5[0].low)*0.382+m5[0].low;
    if(b1&&b2&&b3&&b4) return true;
    return false;
   } 
bool CMultiPeriod::SellCondition(void)
   {
    if(positions.open_sell>0&&latest_price.time-last_sell_time<60*60) return false;
    bool b1=latest_price.bid>(week[0].high-week[0].low)*0.618+week[0].low;
    bool b2=latest_price.bid>(daily[0].high-daily[0].low)*0.618+daily[0].low;
    bool b3=latest_price.bid>(h4[0].high-h4[0].low)*0.618+h4[0].low;
    bool b4=latest_price.bid>(h1[0].high-h1[0].low)*0.618+h1[0].low;
   // bool b5=latest_price.bid>(m5[0].high-m5[0].low)*0.618+m5[0].low;
    if(b1&&b2&&b3&&b4) return true;
    return false;    
   }        
//+------------------------------------------------------------------+
