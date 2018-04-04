//+------------------------------------------------------------------+
//|                                           StrategyCurrencies.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <RiskManage_czj\MarketMoment.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategyCurrencies:public CStrategy
  {
private:
   CurrenciesMoment  moment;
public:
                     CStrategyCurrencies(void);
                    ~CStrategyCurrencies(void);
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
void CStrategyCurrencies::OnEvent(const MarketEvent &event)
   {
    if(event.type==MARKET_EVENT_BAR_OPEN)
      {
       string c[];
       int p[];
       moment.GetCurrenciesMoments(c,p);
       int i_max=ArrayMaximum(p);
       int i_min=ArrayMinimum(p);
       if(p[i_max]>0&&p[i_min]<0)
         {
          string symbol_trade;
          ENUM_ORDER_TYPE order_type=ORDER_TYPE_BUY;
          if(i_max>i_min)
            {
             
            }
          else
            {
             
            }
         }
      }
   }