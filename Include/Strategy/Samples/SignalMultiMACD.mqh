//+------------------------------------------------------------------+
//|                                              SignalMultiMACD.mqh |
//|                                                      Daixiaorong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daixiaorong"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Strategy\SignalAdapter.mqh>

input int               MACD_num=3;
ENUM_TIMEFRAMES         MACD_period[]={PERIOD_M1, PERIOD_M5, PERIOD_M15};
//+------------------------------------------------------------------+
//| Strategy receives events and displays in terminal.               |
//+------------------------------------------------------------------+
class COnSignal_M_MACD : public CStrategy
  {
private:
   CSignalAdapter    m_adapter_macd[];
public:
                     COnSignal_M_MACD(void);
                    ~COnSignal_M_MACD(void);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
  };
//+------------------------------------------------------------------+
//| Initialization of the CSignalMacd signal module                  |
//+------------------------------------------------------------------+ 
COnSignal_M_MACD::COnSignal_M_MACD(void)
  {
   if(MACD_num!=ArraySize(MACD_period))
     {
      printf(__FUNCTION__+":"+"MACD指标数与周期数不对应！");
      return;
     }
   ArrayResize(m_adapter_macd, MACD_num,10);
   MqlSignalParams params;
   params.symbol=Symbol();
   params.every_tick=false;
   params.point=10.0;
   params.usage_pattern=3;
   params.signal_type=SIGNAL_MACD;
   params.symbol=Symbol();
   for(int i=0;i<MACD_num;i++)
     {
      params.magic=32910+i;
      params.period=MACD_period[i];
      CSignalMACD *macd=m_adapter_macd[i].CreateSignal(params);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COnSignal_M_MACD::~COnSignal_M_MACD(void)
  {
  }
//+------------------------------------------------------------------+
//| Buying.                                                          |
//+------------------------------------------------------------------+
void COnSignal_M_MACD::InitBuy(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(positions.open_buy > 0)
      return;
   if(m_adapter_macd[0].LongSignal() && m_adapter_macd[1].LongSignal())
      Trade.Buy(0.1);
}
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void COnSignal_M_MACD::SupportBuy(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(pos.Profit()>= 10.0 || pos.Profit()<=-10.0)
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
//| Selling.                                                         |
//+------------------------------------------------------------------+
void COnSignal_M_MACD::InitSell(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(positions.open_sell > 0)
      return;
   if(m_adapter_macd[0].ShortSignal()&& m_adapter_macd[1].ShortSignal())
      Trade.Sell(0.1);
}
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void COnSignal_M_MACD::SupportSell(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(pos.Profit()>= 10.0 || pos.Profit()<=-10.0)
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
